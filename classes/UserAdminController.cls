public class UserAdminController {

    //Our collection of the class/wrapper objects cContact 
    public List<wrappedUser> userList {get; set;}
    public List<User> selectedUsers {get; set;}
    public String message {get;set;}
    public Boolean showInactive {get;set;}
    
    public UserAdminController() {
        userList = new List<wrappedUser>();
        showInactive = false;
        if(ApexPages.currentPage().getParameters().containsKey('message') )
        {
            message = ApexPages.currentPage().getParameters().get('message');
        }
        else {
            message  = '';        
        }
        

       
    }
    
    
    
    //This method uses a simple SOQL query to return a List of Contacts
    public List<wrappedUser> getUsers(){
        for(User u : [Select u.UserRole.Name, u.UserRoleId, u.Profile.Name, u.Profile.Id, u.ProfileId, u.Name, u.IsActive, u.Id From User u where u.IsActive != :showInactive ORDER BY LastName, FirstName])
        {
            /* As each contact is processed we create a new cContact object and add it to the contactList */
            userList.add(new wrappedUser(u));
        }
        return userList;
    }
    
    public PageReference toggleInactive()
    {
        userList.clear();
        for(User u : [Select u.UserRole.Name, u.UserRoleId, u.Profile.Name, u.Profile.Id, u.ProfileId, u.Name, u.IsActive, u.Id From User u where u.IsActive != :showInactive ORDER BY LastName, FirstName])
        {
            /* As each contact is processed we create a new cContact object and add it to the contactList */
            userList.add(new wrappedUser(u));
        }
        message = 'Filter updated, "show inactive users" set to ' +  showInactive;
        return null;
    }
    
    public PageReference processSelected(){
        message = 'Modified user list = ';
        /*We create a new list of Contacts that we be populated only with Contacts
        if they are selected*/
        List<User> selectedUsers = new List<User>();
        
        /*We will cycle through our list of cContacts and will check to see if the 
        selected property is set to true, if it is we add the Contact to the 
        selectedContacts list. */
        for(wrappedUser w: userList){
            if(w.selected == true){
                selectedUsers.add(w.usr);
                message = message + w.usr.Name +  ' '; 
            }
        }
        
        /* Now we have our list of selected contacts and can perform any type of 
        logic we want, sending emails, updating a field on the Contact, etc */
        try {
            update selectedUsers;
            userList.clear();
            for(User u : [Select u.UserRole.Name, u.UserRoleId, u.Profile.Name, u.Profile.Id, u.ProfileId, u.Name, u.IsActive, u.Id From User u where u.IsActive != :showInactive ORDER BY LastName, FirstName])
            {
            /* As each contact is processed we create a new cContact object and add it to the contactList */
                userList.add(new wrappedUser(u));
            }
            
            PageReference pageRef = Page.UserAdmin;
            pageRef.getParameters().put('message', message ); 
            return pageRef;
        }
        catch(Exception e) {
            message = 'An Error Occurred! Save not committed.' + e.getMessage();
            return null;    
        }
        
    }
    
    /* This is our wrapper/container class. A container class is a class, a data 
    structure, or an abstract data type whose instances are collections of other 
    objects. In this example a wrapper class contains both the standard salesforce 
    object Contact and a Boolean value */
    public class wrappedUser{
        public User usr {get; set;}
        public Boolean selected {get; set;}
        
        /*This is the contructor method. When we create a new cContact object we pass a 
        Contact that is set to the con property. We also set the selected value to false*/
        public wrappedUser(User u){
            usr = u;
            selected = false;
        }
    }
    
    public static testMethod void testUserAdminController() {
        ApexPages.currentPage().getParameters().put('message', 'Starting Test...');
        UserAdminController controllerTest = new UserAdminController();
        try
        {
            controllerTest.getUsers();
            controllerTest.toggleInactive();
            controllerTest.processSelected();   
        }
        catch (System.DmlException e) 
        {
            System.debug('Failed test for UserAdmin tool: ' + e);
        }
        
    } 
}
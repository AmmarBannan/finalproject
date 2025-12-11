class UserService {
    constructor(){
        this.users = [];
    }

    addUser(user){
        user.id = this.users.length + 1;
        this.users.push(user);
        return user;
    }

    getAll(){
        return this.users;
    }
}

module.exports = new UserService();

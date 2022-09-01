const UserCore = require("../models/UserCore");

const createUser = async (userCore) => {
    try {
        const newUser = new UserCore(userCore);

        await newUser.save();
        console.log("UserCoreService: Successfully added new userCore");
    } catch(e) {
        console.log("UserCoreService: Failed to add new user")
        throw e;
    }
};

const getUser = async (uid) => {
    try {
        const queryParams = {
            "userBasic.uid": uid
        };

        const returnedUser = await UserCore.find(queryParams).exec();
        console.log("UserCoreService: Successfully fetched userCore");
        return returnedUser[0];
    } catch(e) {
        console.log("UserCoreService: Failed to fetch userCore");
        throw e;
    }
};

const updateUser = async (userCore) => {
    try {
        const filter = {
            "userBasic.uid": userCore.userBasic.uid
        };

        await UserCore.findOneAndUpdate(filter, userCore);
        console.log("UserCoreService: Successfully updated user");
    } catch(e) {
        throw e;
    }
};

const deleteUser = async (uid) => {
    try {
        const filter = {
            "userBasic.uid": uid
        };
        await UserCore.findOneAndDelete(filter);
        console.log("UserCoreService: Successfully deleted user");
    } catch(e) {
        throw e;
    }
};

module.exports = {
    createUser,
    getUser,
    updateUser,
    deleteUser
}
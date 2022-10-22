const Story = require("../models/Story");
const UserCore = require("../models/UserCore");
const helpers = require("../services/helpers");

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

const getUsersWithPosts = async (userCore, ninUIDs, localSearch, limit) => {

    if (userCore) {
        try {
            let queryParams = helpers.gatherQueryParamsForLocal(userCore, localSearch);

            if(queryParams.length == 1) {
                let queryParams1 = queryParams[0];

                queryParams1["userBasic.uid"] = {
                    $nin: ninUIDs
                };

                queryParams1["mostRecentStory"] = {
                    $exists: true
                };

                const users = await UserCore.find(queryParams1).limit(limit);

                return users;

            } else if (queryParams.length == 2){
                let queryParams1 = queryParams[0];
                let queryParams2 = queryParams[1];

                const notIn = ninUIDs.push(userCore["userBasic.uid"]);

                queryParams1["userBasic.uid"] = {
                    $nin: notIn
                };

                queryParams2["userBasic.uid"] = {
                    $nin: notIn
                };

                queryParams1["mostRecentStory"] = {
                    $exists: true
                };

                queryParams2["mostRecentStory"] = {
                    $exists: true
                };

                const [first, second] = await Promise.all([
                    UserCore.find(queryParams1).limit(Math.round((limit) / 2)),
                    UserCore.find(queryParams2).limit(Math.round((limit) / 2))
                ]);

                let final = first.concat(second);
                return final;
            }
        } catch(e) {
            console.log("UserCoreService error: " + e);
            payload = {
                error: "UserCoreService/getUsersWithPosts: Failed to fetch users with post",
                description: e
            };

            throw payload;
        }
    } else {
        const payload = {
            error: "UserCoreService/getUsersWithPosts: Empty UserCore"
        };

        throw e;
    }
};

module.exports = {
    createUser,
    getUser,
    updateUser,
    deleteUser,
    getUsersWithPosts
}
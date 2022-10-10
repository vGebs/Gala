const UserCore = require("../models/UserCore");
const RecentlyJoinedView = require("../models/RecentlyJoinedView");
const helpers = require("../services/helpers");

// GeoQuery: https://dev.to/vcpablo/4-ways-to-find-geojson-data-in-mongodb-14pb

const getRecents = async (currentUserCore, matches, localSearch) => {
    //We need to first fetch:
    //  1. Our matches
    //  2. profiles we've already viewed
    //When a user views a profile from recentlyJoined we submit it as viewed

    try {
        const viewedProfiles = await fetchAllViewedProfiles(currentUserCore.userBasic.uid);

        //we now have to add our matches, viewedProfiles, and our own uid to an array
        let notInArray = [currentUserCore.userBasic.uid];
        notInArray = notInArray.concat(matches, viewedProfiles);

        const sexualityAndGender = helpers.getSexualityAndGender(currentUserCore.userBasic)

        const queryParams = helpers.gatherQueryParamsForLocal(currentUserCore, localSearch);

        if (queryParams.length == 1) {
            const queryParams1 = queryParams[0];

            queryParams1["userBasic.uid"] = {
                $nin: notInArray
            };

            const currentDate = new Date();

            queryParams1["userBasic.dateJoined"] = {
                $gt: currentDate.getDate() - 7
            };

            const recentResults = await UserCore.find(queryParams1);

            return recentResults;

        } else if (queryParams.length == 2) {
            const queryParams1 = queryParams[0];
            const queryParams2 = queryParams[1];

            queryParams1["userBasic.uid"] = {
                $nin: notInArray
            };

            const currentDate = new Date();
            //greater than 7 days ago

            queryParams1["userBasic.dateJoined"] = {
                $gt: currentDate.getDate() - 7
            };

            queryParams2["userBasic.uid"] = {
                $nin: notInArray
            };

            queryParams2["userBasic.dateJoined"] = {
                $gt: currentDate.getDate() - 7
            };

            const [first, second] = await Promise.all([
                UserCore.find(queryParams1),
                UserCore.find(queryParams2)
            ]);
            let final = first.concat(second);
            return final;
        }
    } catch (e) {
        console.log("getRecents: failed");
        console.log(e);
        throw e;
    }
};

const viewRecentlyJoinedProfile = async (currentUser, userViewed) => {
    try {
        const payload = {
            viewerUID: currentUser,
            viewedUID: userViewed
        }
        const view = new RecentlyJoinedView(payload);
        await view.save();
        console.log("RecentlyJoinedUserService: Successfully added new view from");
    } catch (e) {
        throw e;
    }
};

module.exports = {
    getRecents,
    viewRecentlyJoinedProfile
};

const fetchAllViewedProfiles = async (uid) => {
    try {
        let queryParams = {
            "viewerUID": uid
        };

        let profiles = await RecentlyJoinedView.find(queryParams);
        let returnedUIDs = [];

        for (i = 0; i < profiles.length; i++) {
            returnedUIDs.push(profiles[i].viewedUID);
        }

        return returnedUIDs;
    } catch (e) {
        throw e
    }
};
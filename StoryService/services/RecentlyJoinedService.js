const UserCore = require("../models/UserCore");
const RecentlyJoinedView = require("../models/RecentlyJoinedView")

// GeoQuery: https://dev.to/vcpablo/4-ways-to-find-geojson-data-in-mongodb-14pb

const getRecents = async (currentUserCore, matches) => {
    //We need to first fetch:
    //  1. Our matches
    //  2. profiles we've already viewed
    //When a user views a profile from recentlyJoined we submit it as viewed

    try {
        const viewedProfiles = await fetchAllViewedProfiles(currentUserCore.userBasic.uid);

        //we now have to add our matches, viewedProfiles, and our own uid to an array
        let notInArray = [currentUserCore.userBasic.uid];
        notInArray = notInArray.concat(matches, viewedProfiles);

        const sexualityAndGender = getSexualityAndGender(currentUserCore.userBasic)

        let queryParams;
        let queryParams2;

        if (sexualityAndGender == "StraightMale") {
            queryParams = {
                "userBasic.gender": "female",
                "userBasic.sexuality": {
                    $in: ["straight", "bisexual"]
                }
            };
        } else if (sexualityAndGender == "StraightFemale") {
            queryParams = {
                "userBasic.gender": "male",
                "userBasic.sexuality": {
                    $in: ["straight", "bisexual"]
                }
            };
        } else if (sexualityAndGender == "GayMale") {
            queryParams = {
                "userBasic.gender": "male",
                "userBasic.sexuality": {
                    $in: ["gay", "bisexual"]
                }
            };
        } else if (sexualityAndGender == "GayFemale") {
            queryParams = {
                "userBasic.gender": "female",
                "userBasic.sexuality": {
                    $in: ["gay", "bisexual"]
                }
            };
        } else if (sexualityAndGender == "BiMale") {
            queryParams = {
                "userBasic.gender": "male",
                "userBasic.sexuality": {
                    $in: ["gay", "bisexual"]
                }
            };

            queryParams2 = {
                "userBasic.gender": "female",
                "userBasic.sexuality": {
                    $in: ["straight", "bisexual"]
                }
            };

        } else if (sexualityAndGender == "BiFemale") {

            queryParams = {
                "userBasic.gender": "female",
                "userBasic.sexuality": {
                    $in: ["gay", "bisexual"]
                }
            };

            queryParams2 = {
                "userBasic.gender": "male",
                "userBasic.sexuality": {
                    $in: ["straight", "bisexual"]
                }
            };
        }

        if (queryParams2 === undefined) {
            queryParams["userBasic.uid"] = {
                $nin: notInArray
            };

            queryParams["searchRadiusComponents.location"] = {
                $nearSphere: {
                    $geometry: {
                        type: "Point",
                        coordinates: [
                            parseFloat(currentUserCore.searchRadiusComponents.location.coordinates[0]),
                            parseFloat(currentUserCore.searchRadiusComponents.location.coordinates[1])
                        ]
                    },
                    $maxDistance: currentUserCore.searchRadiusComponents.willingToTravel * 1000,
                    $minDistance: 0
                }
            };

            const recentResults = await UserCore.find(queryParams);

            return recentResults;
        } else {
            queryParams["userBasic.uid"] = {
                $nin: notInArray
            };

            queryParams2["userBasic.uid"] = {
                $nin: notInArray
            };

            queryParams["searchRadiusComponents.location"] = {
                $nearSphere: {
                    $geometry: {
                        type: "Point",
                        coordinates: [
                            parseFloat(currentUserCore.searchRadiusComponents.location.coordinates[0]),
                            parseFloat(currentUserCore.searchRadiusComponents.location.coordinates[1])
                        ]
                    },
                    $maxDistance: currentUserCore.searchRadiusComponents.willingToTravel * 1000,
                    $minDistance: 0
                }
            };

            queryParams2["searchRadiusComponents.location"] = {
                $nearSphere: {
                    $geometry: {
                        type: "Point",
                        coordinates: [
                            parseFloat(currentUserCore.searchRadiusComponents.location.coordinates[0]),
                            parseFloat(currentUserCore.searchRadiusComponents.location.coordinates[1])
                        ]
                    },
                    $maxDistance: currentUserCore.searchRadiusComponents.willingToTravel * 1000,
                    $minDistance: 0
                }
            };

            const [first, second] = await Promise.all([
                UserCore.find(queryParams),
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

const SexualityAndGender_Enum = {
    StraightMale: "StraightMale",
    StraightFemale: "StraightFemale",

    GayMale: "GayMale",
    GayFemale: "GayFemale",

    BiMale: "BiMale",
    BiFemale: "BiFemale"
};

const getSexualityAndGender = (userBasic) => {
    if (userBasic.sexuality == "straight" && userBasic.gender == "male") {
        //straight male
        return SexualityAndGender_Enum.StraightMale

    } else if (userBasic.sexuality == "straight" && userBasic.gender == "female") {
        //straight female
        return SexualityAndGender_Enum.StraightFemale

    } else if (userBasic.sexuality == "gay" && userBasic.gender == "male") {
        //gay male
        return SexualityAndGender_Enum.GayMale

    } else if (userBasic.sexuality == "gay" && userBasic.gender == "female") {
        //gay female
        return SexualityAndGender_Enum.GayFemale;

    } else if (userBasic.sexuality == "bisexual" && userBasic.gender == "male") {
        //bi male
        return SexualityAndGender_Enum.BiMale;

    } else if (userBasic.sexuality == "bisexual" && userBasic.gender == "female") {
        //bi female
        return SexualityAndGender_Enum.BiFemale;
    }
};
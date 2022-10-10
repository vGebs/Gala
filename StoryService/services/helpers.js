const bundleUserCore = (req) => {
    const userCore = {
        userBasic: {
            uid: req.body.UserCore.userBasic.uid,
            name: req.body.UserCore.userBasic.name,
            birthdate: req.body.UserCore.userBasic.birthdate,
            gender: req.body.UserCore.userBasic.gender,
            sexuality: req.body.UserCore.userBasic.sexuality,
            dateJoined: req.body.UserCore.userBasic.dateJoined
        },
        ageRangePreference: {
            maxAge: req.body.UserCore.ageRangePreference.maxAge,
            minAge: req.body.UserCore.ageRangePreference.minAge,
        },
        searchRadiusComponents: {
            willingToTravel: req.body.UserCore.searchRadiusComponents.willingToTravel,
            location: {
                coordinates: req.body.UserCore.searchRadiusComponents.location.coordinates
            }
        }
    }

    return userCore
}

const gatherQueryParamsForLocal = (currentUserCore, localSearch) => {
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

        if (localSearch) {
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
        }

        return [queryParams];
    } else {

        if (localSearch) {
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
        }

        return [queryParams, queryParams2];
    }
}

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

module.exports = {
    bundleUserCore,
    gatherQueryParamsForLocal,
    getSexualityAndGender
};

const SexualityAndGender_Enum = {
    StraightMale: "StraightMale",
    StraightFemale: "StraightFemale",

    GayMale: "GayMale",
    GayFemale: "GayFemale",

    BiMale: "BiMale",
    BiFemale: "BiFemale"
};
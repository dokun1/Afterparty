var Image = require("parse-image");
 
Parse.Cloud.define("attemptPhotoCleanup", function(request, response) {
    var hasDeletedAllPhotos = false;
    var deletedEventID = request.params.eventID;
    var Photos = Parse.Object.extend("Photos");
    var query = new Parse.Query(Photos);
    query.equalTo("eventID", deletedEventID);
        query.find({
        success: function(results) {
            var successCounter = results.length;
            if (successCounter == 0) {
                response.success(0);
                return;
            }
            console.log("event " + deletedEventID + " has " + successCounter + " photos to delete in total.");
            var photosToDeleteCount = 10;
            if (results.length < 10) {
                photosToDeleteCount = results.length;
            }
            console.log(photosToDeleteCount + " photos to delete");
            for (var i = 0; i < photosToDeleteCount; i++) {
                var photoObject = results[i];
                var refID = photoObject.get("refID");
                console.log("deleting photo " + refID);
                photoObject.destroy({
                    success:function() {
                        console.log("deleted photo from event " + deletedEventID);
                        successCounter = successCounter - 1;
                    },
                    error:function() {
                        console.log("could not delete photo " + photoObject.get("refID") + " from event " + deletedEventID);
                    }
                });
            }
            response.success(results.length - photosToDeleteCount);
        },
        error: function() {
            response.error("Could not find any photos for ID " + deletedEventID);
        }
    });
});
 
Parse.Cloud.define("notifyPartyUpdate", function(request, response) {
    var eventID = request.params.eventID;
    var thisUserID = request.params.userID;
    var EventSearch = Parse.Object.extend("EventSearch");
    var query = new Parse.Query(EventSearch);
    console.log("trying to notify people of a party update.");
    query.get(eventID, {
        success: function(event) {
            var installArray = event.get("attendees");   
            var eventName = event.get("eventName");
            var eventID = event.get("objectId");
            console.log("captured array with contents: " + installArray);
            var installQuery = new Parse.Query(Parse.Installation);
            installQuery.containedIn("user", event.get("attendees"));
            Parse.Push.send({
                where: installQuery,
                data: {
                    alert: eventName + " has changed! Go log in and see what happened.",
                    eventID: eventID,
                    eventObject: event
                }
            }, {
                success: function () {
                    //push successful
                },
                error: function(error) {
                    //push not successful
                }
            });
        },
        error: function(error) {
            console.log("Failed to find event " + eventID);
        }
    });
});
 
Parse.Cloud.afterSave("Photos", function(request) {
    var photoObject = request.object;
    var refID = photoObject.get("refID");
    console.log("checking reporting number after photo save for ref id " + refID);
    var reports = photoObject.get("reports");
    if (reports > 2) {
        console.log("photo " + refID + " needs to be destroyed due to reporting.");
        photoObject.destroy({
            success:function() {
                console.log("deleted photo " + refID + " due to reporting.");   
            },
            error:function(error) {
                console.log("could not delete photo " + refID);
            }
        });
    }
    var query = new Parse.Query(Parse.User);
    query.equalTo("username", photoUser);
    query.get(request.object.get("user").id, {
        success: function(photoUser) {
            user.increment("photoUploadCount");
            user.save();
        },
        error: function() {
            console.log("Could not increment photo count for user " + photoUser);
        }
    });
});
 
Parse.Cloud.beforeSave("Photos", function(request, response) {
  var photoObject = request.object;
  if (!photoObject.get("imageFile")) {
    response.error("ImageFile did not properly upload");
    return;
  }
  if (photoObject.get("thumbFile")) {
      console.log("already a thumbfile for this photo, no need to construct another thumbnail.");
      response.success();
      return;
  }
   
Parse.Cloud.httpRequest({
    url: photoObject.get("imageFile").url()
   
  }).then(function(response) {
    var image = new Image();
    return image.setData(response.buffer);
  }).then(function(image) {
    // Resize the image to 20% of original size.
    return image.scale({
        ratio:0.20
    });
   
  }).then(function(image) {
    // Make sure it's a JPEG to save disk space and bandwidth.
    return image.setFormat("JPEG");
   
  }).then(function(image) {
    // Get the image data in a Buffer.
    return image.data();
   
  }).then(function(buffer) {
    // Save the image into a new file.
    var base64 = buffer.toString("base64");
    var cropped = new Parse.File("thumb.jpg", { base64: base64 });
    return cropped.save();
   
  }).then(function(altered) {
    // Attach the image file to the original object.
    photoObject.set("thumbFile", altered);
   
  }).then(function(result) {
    response.success();
  }, function(error) {
    response.error(error);
  });
});
// From https://stackoverflow.com/questions/35662409/parse-server-cloud-code-setting-acl/35663851#35663851
Parse.Cloud.beforeSave('Account', function (req, res) {
  setCreatorOnlyAccess(req);
  res.success();
});
Parse.Cloud.beforeSave('Transaction', function (req, res) {
  setCreatorOnlyAccess(req);
  res.success();
});
Parse.Cloud.beforeSave('Category', function (req, res) {
  setCreatorOnlyAccess(req);
  res.success();
});

function setCreatorOnlyAccess(req) {
  var acl = new Parse.ACL();
  acl.setReadAccess(req.user, true);
  acl.setWriteAccess(req.user, true);
  acl.setPublicReadAccess(false);
  acl.setPublicWriteAccess(false);
  req.object.setACL(acl);
}

Parse.Cloud.beforeSave(Parse.User, function (request, response) {
  if (!request.object.existed()) {
    var acl = new Parse.ACL();
    acl.setPublicReadAccess(false);
    acl.setPublicWriteAccess(false);
    request.object.setACL(acl);
  }
  response.success();
});

// Parse.Cloud.afterSave(Parse.User, function (request, res) {
//   var user = request.object;
//   if (!user.existed()) {
//     // ACL - only user can read and write
//     var acl = new Parse.ACL();
//     acl.setReadAccess(req.user, true);
//     acl.setWriteAccess(req.user, true);
//     acl.setPublicReadAccess(false);
//     acl.setPublicWriteAccess(false);
//     user.setACL(acl);
//     user.save();
//   }
// });

// // Shout out to https://stackoverflow.com/questions/28702524/parse-com-signup-user-to-role
// Parse.Cloud.define("signupAsBasicUser", function (req, response) {
//   signupAsBasicUser(req.params.username, req.params.password).then(function (user) {
//     response.success(user);
//   }, function (error) {
//     response.error(error);
//   });
// });

// // return a promise fulfilled with a signed-up user who is added to the 'Basic User" role
// //
// function signupAsBasicUser(username, password) {
//   Parse.Cloud.useMasterKey();
//   var user = new Parse.User();
//   user.set("username", username);
//   user.set("password", password);
//   user.set("email", username);
//   return user.signUp().then(function () {
//     query.equalTo("name", 'Basic User');
//     var query = new Parse.Query(Parse.Role);
//     return query.find();
//   }).then(function (roles) {
//     if (roles.length < 1) return Parse.Promise.error("no such role");
//     roles[0].getUsers().add(user);
//     return roles[0].save();
//   }).then(function () {
//     return user;
//   });
// }

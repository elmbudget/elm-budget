var Parse = require('parse/node');

var serverUrl = process.argv[2]
var appId = process.argv[3];
var masterKey = process.argv[4];


console.log(appId);

if (!serverUrl || !appId || !masterKey) {
  console.log('Requires 2 arguments: serverurl, appId, masterKey');
  process.exit(-1);
}

Parse.initialize(appId, null, masterKey);
Parse.serverURL = serverUrl;
Parse.Cloud.useMasterKey();

const basicUserRoleName = 'Basic User';

void async function () {

  // ---------------------------------------------
  // Setup ROLES
  // ---------------------------------------------

  // // Check existing roles
  // console.log('Existing Roles');
  // var query = new Parse.Query(Parse.Role);
  // var existingRoles = await query.find();
  // console.log(existingRoles);

  // if (existingRoles.find(r => r.getName() == basicUserRoleName)) {
  //   console.log(`There is already a role named '${basicUserRoleName}'. Skipping role creation`);
  // }
  // else {
  //   // Create Basic User Role
  //   console.log('Creating role...')
  //   var roleACL = new Parse.ACL();
  //   roleACL.setPublicReadAccess(false); // Disable any access: Role is only used by code with master key access anyway.
  //   roleACL.setPublicWriteAccess(false);
  //   var role = new Parse.Role(basicUserRoleName, roleACL);
  //   await role.save();
  //   console.log('Role created.')
  // }


  // // ---------------------------------------------
  // // Setup USER
  // // ---------------------------------------------

  // var response = await Parse._request(
  //   'PUT',
  //   'schemas/User',
  //   {
  //     classLevelPermissions: {
  //       find: { "role:admin": true },
  //       get: { "*": true },
  //       create: { "*": true },
  //       update: { "requiresAuthentication": true },
  //       delete: { "requiresAuthentication": true },
  //       addField: { "requiresAuthentication": true }
  //     }
  //   }
  // );
  // ---------------------------------------------
  // Setup CLASSES
  // ---------------------------------------------

  var classes = ['Account', 'Transaction', 'Category'];

  await Promise.all(classes.map(async (className) => {
    console.log(`Creating object for ${className} class...`);
    var Account = Parse.Object.extend(className);
    var obj = new Account();
    var obj2 = await obj.save();
    console.log('done');
    console.log('Removing dummy object...')
    await obj2.destroy();
    console.log('done');

    console.log('setting permissions');

    // // Pinched from https://github.com/parse-community/parse-server/issues/891
    // var schema = await Parse._request(
    //   'GET',
    //   `schemas/${className}`
    // )

    // console.log('existing permissions are:');
    // console.log(schema.classLevelPermissions);

    schemaUpd = {};
    schemaUpd.classLevelPermissions = {
      find: { "requiresAuthentication": true, "*": true },
      get: { "requiresAuthentication": true },
      create: { "requiresAuthentication": true },
      update: { "requiresAuthentication": true },
      delete: { "requiresAuthentication": true },
      addField: { "requiresAuthentication": true }
    };

    var response = await Parse._request(
      'PUT',
      'schemas/' + className,
      schemaUpd
    );

    console.log(response);

    console.log('done done');
  }));

}().catch((error) => {
  console.log('Error occurred during setup:')
  console.log(error);
  process.exit(-1);
});
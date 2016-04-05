var crypto = require('crypto');


// calculate the md5 hash of this asset's contents
module.exports = function hash (input) {
  return crypto.createHash('md5').update(input).digest('hex');
};

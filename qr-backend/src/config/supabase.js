const { StorageClient } = require('@supabase/storage-js');

const storageUrl = `${process.env.SUPABASE_URL}/storage/v1`;

const storageClient = new StorageClient(storageUrl, {
  apikey:        process.env.SUPABASE_SERVICE_KEY,
  Authorization: `Bearer ${process.env.SUPABASE_SERVICE_KEY}`,
});

module.exports = storageClient;

const localtunnel = require('localtunnel');

(async () => {
  try {
    const tunnel = await localtunnel({ port: 3000, subdomain: 'fitlens-api-uzair' });

    console.log('====================================================');
    console.log(' FitLens Public HTTPS Tunnel is Live!');
    console.log(` Public Server URL: ${tunnel.url}`);
    console.log(' Use this URL on your phone anywhere (Wi-Fi or 4G)!');
    console.log('====================================================');

    tunnel.on('close', () => {
      console.log('Tunnel closed');
    });

    tunnel.on('error', (err) => {
      console.error('Tunnel error:', err);
    });
  } catch (err) {
    console.error('Failed to create tunnel:', err);
  }
})();

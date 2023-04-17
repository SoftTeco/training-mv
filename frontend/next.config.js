/** @type {import('next').NextConfig} */
const nextConfig = {
  serverRuntimeConfig: {
    apiUrl: process.env.API_URL,
    //apiUrl: `http://localhost:3002`,
  },
  reactStrictMode: true,
};

module.exports = nextConfig;

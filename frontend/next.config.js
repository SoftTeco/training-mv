/** @type {import('next').NextConfig} */
const nextConfig = {
  serverRuntimeConfig: {
    apiUrl: process.env.API_URL,
  },
  reactStrictMode: true,
};

module.exports = nextConfig;

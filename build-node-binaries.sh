cd nodejs
yarn build-communication-test
cp build/main.js ../Tests/IntegrationTests/Resources/NodeJsCommunicationTest.js
yarn build
mkdir ../Sources/Gammaray/Resources
cp build/main.js ../Sources/Gammaray/Resources/NodeJsAppProcess.js

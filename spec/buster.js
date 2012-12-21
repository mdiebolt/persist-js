var config = module.exports;

config["My tests"] = {
  env: "browser", // or "node"
  extensions: [require('buster-coffee')],
  rootPath: "../",
  sources: [
    "source/**/*.coffee"
  ],
  tests: [
    "spec/*_spec.coffee"
  ]
};

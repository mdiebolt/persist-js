var config = module.exports;

config["My tests"] = {
  env: "browser", // or "node"
  extensions: [require('buster-coffee')],
  rootPath: "../",
  sources: [
    "javascripts/*.coffee"
  ],
  tests: [
    "spec/*_spec.coffee"
  ]
};

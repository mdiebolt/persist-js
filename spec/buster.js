var config = module.exports;

config["My tests"] = {
  env: "browser",
  extensions: [require('buster-coffee')],
  rootPath: "../",
  sources: [
    "javascripts/*.coffee"
  ],
  tests: [
    "spec/*_spec.coffee"
  ]
};

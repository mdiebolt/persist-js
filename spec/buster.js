var config = module.exports;

config["My tests"] = {
  env: "browser",
  extensions: [require('buster-coffee')],
  rootPath: "../",
  sources: [
    "javascripts/*.coffee.md"
  ],
  tests: [
    "spec/*_spec.coffee"
  ]
};

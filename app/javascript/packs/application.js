import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";

require("@rails/ujs").start();
require("turbolinks").start();
require("channels");

require("stylesheets/application.scss");

const application = Application.start();
const context = require.context("../controllers", true, /\.js$/);
application.load(definitionsFromContext(context));

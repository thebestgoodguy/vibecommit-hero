import { apiInitializer } from "discourse/lib/api";
import VibecommitHero from "../components/vibecommit-hero";

export default apiInitializer("1.15.0", (api) => {
  api.renderInOutlet(settings.plugin_outlet, VibecommitHero);
});

import { click, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";

acceptance("Vibecommit Hero - Logged out", function () {
  test("hero can be hidden from anons", async function (assert) {
    settings.show_for_anon = false;
    await visit("/");
    assert.dom(".vibecommit-hero").doesNotExist("hides the hero for anons");
  });

  test("hero can be shown to anons", async function (assert) {
    settings.show_for_anon = true;
    await visit("/");
    assert.dom(".vibecommit-hero").exists("shows the hero for anons");
  });
});

acceptance("Vibecommit Hero - Logged in", function (needs) {
  needs.user();

  test("hero can be hidden from members", async function (assert) {
    settings.show_for_members = false;
    await visit("/");
    assert.dom(".vibecommit-hero").doesNotExist("hides the hero for members");
  });

  test("hero can be shown to members", async function (assert) {
    settings.show_for_members = true;
    await visit("/");
    assert.dom(".vibecommit-hero").exists("shows the hero for members");
  });
});

acceptance("Vibecommit Hero - Routing", function () {
  settings.show_for_anon = true;
  settings.url_must_contain = "/c/*";

  test("hero is visible on the homepage", async function (assert) {
    settings.display_on_homepage = true;
    await visit("/");
    assert.dom(".vibecommit-hero").exists("shows the hero on the homepage");
  });

  test("hero is hidden from the homepage", async function (assert) {
    settings.display_on_homepage = false;
    await visit("/");
    assert.dom(".vibecommit-hero").doesNotExist("hides the hero on the homepage");
  });

  test("hero is visible on a set route", async function (assert) {
    settings.display_on_homepage = false;
    await visit("/c/1");

    assert.dom(".vibecommit-hero").exists("shows the hero on the /c/* route");
  });

  test("hero is not visible on other routes", async function (assert) {
    settings.display_on_homepage = false;
    await visit("/u");

    assert
      .dom(".vibecommit-hero")
      .doesNotExist("does not show the hero on the /u route");
  });
});

acceptance("Vibecommit Hero - Visibility", function () {
  test("hero can be expanded", async function (assert) {
    settings.show_for_anon = true;
    settings.collapsible = true;
    settings.default_collapsed_state = "collapsed";

    const encodedCookieValue = encodeURIComponent(
      JSON.stringify({
        name: "vibecommit-hero-v1",
        collapsed: true,
      })
    );

    document.cookie = `hero_collapsed=${encodedCookieValue}; path=/;`;

    await visit("/");
    await click("button.toggle-hero");

    assert
      .dom(".--hero-collapsed")
      .doesNotExist("the hero does not have the collapsed class");
  });

  test("hero can be collapsed", async function (assert) {
    settings.collapsible = true;
    settings.default_collapsed_state = "expanded";

    const encodedCookieValue = encodeURIComponent(
      JSON.stringify({
        name: "vibecommit-hero-v1",
        collapsed: false,
      })
    );

    document.cookie = `hero_collapsed=${encodedCookieValue}; path=/;`;

    await visit("/");
    await click(".vibecommit-hero button.toggle-hero");

    assert
      .dom(".--hero-collapsed")
      .exists("the hero has the collapsed class");
  });

  test("hero can be dismissed", async function (assert) {
    settings.dismissible = true;
    settings.cookie_lifespan = "none";

    await visit("/");
    await click(".vibecommit-hero button.close-hero");

    assert.dom(".vibecommit-hero").doesNotExist("the hero can be dismissed");
  });
});

import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { and } from "truth-helpers";
import DButton from "discourse/components/d-button";
import htmlSafe from "discourse/helpers/html-safe";
import cookie, { removeCookie } from "discourse/lib/cookie";
import { convertIconClass } from "discourse/lib/icon-library";
import { defaultHomepage } from "discourse/lib/utilities";
import { i18n } from "discourse-i18n";
import icon from "discourse/helpers/d-icon";

export default class VibecommitHero extends Component {
  @service router;
  @service site;
  @service currentUser;

  @tracked bannerClosed = this.cookieClosed || false;
  @tracked
  bannerCollapsed =
    this.collapsedFromCookie !== null
      ? this.collapsedFromCookie
      : this.isDefaultCollapsed;

  cookieClosed = cookie("hero_closed");
  cookieCollapsed = cookie("hero_collapsed");
  isDefaultCollapsed = settings.default_collapsed_state === "collapsed";
  collapsedFromCookie = this.cookieCollapsed
    ? JSON.parse(this.cookieCollapsed).collapsed
    : null;

  get cookieExpirationDate() {
    if (settings.cookie_lifespan === "none") {
      removeCookie("hero_closed", { path: "/" });
      removeCookie("hero_collapsed", { path: "/" });
    } else {
      return moment().add(1, settings.cookie_lifespan).toDate();
    }
  }

  get displayForUser() {
    return (
      (settings.show_for_members && this.currentUser) ||
      (settings.show_for_anon && !this.currentUser)
    );
  }

  get showOnRoute() {
    const path = this.router.currentURL;

    if (
      settings.display_on_homepage &&
      this.router.currentRouteName === `discovery.${defaultHomepage()}`
    ) {
      return true;
    }

    if (settings.url_must_contain.length) {
      const allowedPaths = settings.url_must_contain.split("|");
      return allowedPaths.some((allowedPath) => {
        if (allowedPath.slice(-1) === "*") {
          return path.indexOf(allowedPath.slice(0, -1)) === 0;
        }
        return path === allowedPath;
      });
    }
  }

  get shouldShow() {
    return this.displayForUser && this.showOnRoute;
  }

  get toggleLabel() {
    return this.bannerCollapsed
      ? i18n(themePrefix("toggle.expand_label"))
      : i18n(themePrefix("toggle.collapse_label"));
  }

  get toggleIcon() {
    return this.bannerCollapsed ? "chevron-down" : "chevron-up";
  }

  @action
  closeBanner() {
    this.bannerClosed = true;

    if (this.cookieExpirationDate) {
      const heroState = { name: settings.cookie_name, closed: "true" };
      cookie("hero_closed", JSON.stringify(heroState), {
        expires: this.cookieExpirationDate,
        path: "/",
      });
    }
  }

  @action
  toggleBanner() {
    this.bannerCollapsed = !this.bannerCollapsed;
    let heroState = {
      name: settings.cookie_name,
      collapsed: this.bannerCollapsed,
    };

    if (this.cookieExpirationDate) {
      if (this.cookieCollapsed) {
        heroState = JSON.parse(this.cookieCollapsed);
        heroState.collapsed = this.bannerCollapsed;
      }
    } else {
      heroState.collapsed = this.bannerCollapsed;
    }

    cookie("hero_collapsed", JSON.stringify(heroState), {
      expires: this.cookieExpirationDate,
      path: "/",
    });
  }

  <template>
    {{#if this.shouldShow}}
      {{#unless this.bannerClosed}}
        <section class="vibecommit-hero">
          <!-- Control buttons -->
          <div class="hero-controls">
            {{#if settings.dismissible}}
              <DButton
                @action={{this.closeBanner}}
                @translatedLabel={{i18n (themePrefix "close.label")}}
                @translatedTitle={{i18n (themePrefix "close.title")}}
                @icon="xmark"
                class="close-hero"
              />
            {{/if}}
            {{#if settings.collapsible}}
              <DButton
                @action={{this.toggleBanner}}
                @translatedLabel={{this.toggleLabel}}
                @translatedTitle={{i18n (themePrefix "toggle.title")}}
                @icon={{this.toggleIcon}}
                class="toggle-hero"
              />
            {{/if}}
          </div>

          <!-- Background gradients and image -->
          <div class="hero-background">
            <div class="gradient-overlay-1"></div>
            <div class="gradient-overlay-2"></div>
            {{#if settings.hero_background_image}}
              <div class="hero-bg-image" style="background-image: url({{settings.hero_background_image}});"></div>
            {{/if}}
            <div class="dark-overlay"></div>
            <!-- Floating orbs -->
            <div class="floating-orb orb-1"></div>
            <div class="floating-orb orb-2"></div>
            <div class="floating-orb orb-3"></div>
            <!-- Accent lines -->
            <div class="accent-line line-1"></div>
            <div class="accent-line line-2"></div>
            <div class="accent-line line-3"></div>
            <div class="accent-line line-4"></div>
          </div>

          <!-- Content -->
          <div class="hero-content" class={{if (and settings.collapsible this.bannerCollapsed) "--hero-collapsed"}}>
            <div class="hero-container">
              <div class="hero-inner">
                <!-- Badge -->
                {{#if settings.hero_badge_text}}
                  <div class="hero-badge">
                    <div class="badge-dot"></div>
                    <div class="badge-ping"></div>
                    <span class="badge-text">{{htmlSafe settings.hero_badge_text}}</span>
                    <div class="badge-icons">
                      {{icon "sparkles" class="badge-icon-1"}}
                      {{icon "star" class="badge-icon-2"}}
                    </div>
                  </div>
                {{/if}}

                <!-- Main heading -->
                <div class="hero-heading">
                  <h1 class="hero-title">
                    {{#if settings.hero_title_prefix}}
                      <span class="title-prefix">{{htmlSafe settings.hero_title_prefix}} </span>
                    {{/if}}
                    {{#if settings.hero_title_main}}
                      <span class="title-main">
                        <span class="title-main-text">{{htmlSafe settings.hero_title_main}}</span>
                        <div class="title-glow"></div>
                      </span>
                    {{/if}}
                    {{#if settings.hero_title_suffix}}
                      <span class="title-suffix"> {{htmlSafe settings.hero_title_suffix}}</span>
                    {{/if}}
                  </h1>
                  
                  {{#if settings.hero_description}}
                    <p class="hero-description">{{htmlSafe settings.hero_description}}</p>
                  {{/if}}
                </div>

                <!-- CTA Buttons -->
                {{#if (or settings.primary_button_text settings.secondary_button_text)}}
                  <div class="hero-buttons">
                    {{#if settings.primary_button_text}}
                      <a href="{{settings.primary_button_url}}" class="hero-btn hero-btn-primary">
                        <div class="btn-shine"></div>
                        <div class="btn-content">
                          {{#if settings.primary_button_icon}}
                            {{icon settings.primary_button_icon class="btn-icon"}}
                          {{/if}}
                          {{htmlSafe settings.primary_button_text}}
                          {{icon "arrow-right" class="btn-arrow"}}
                        </div>
                      </a>
                    {{/if}}
                    {{#if settings.secondary_button_text}}
                      <a href="{{settings.secondary_button_url}}" class="hero-btn hero-btn-secondary">
                        {{#if settings.secondary_button_icon}}
                          {{icon settings.secondary_button_icon class="btn-icon"}}
                        {{/if}}
                        {{htmlSafe settings.secondary_button_text}}
                      </a>
                    {{/if}}
                  </div>
                {{/if}}
              </div>
            </div>
          </div>

          <!-- Bottom gradient -->
          <div class="hero-bottom-gradient"></div>
        </section>
      {{/unless}}
    {{/if}}
  </template>
}

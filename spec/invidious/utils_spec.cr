require "../spec_helper"

Spectator.describe "Utils" do
  describe "decode_date" do
    it "parses short dates (en-US)" do
      expect(decode_date("1s ago")).to be_close(Time.utc - 1.second, 500.milliseconds)
      expect(decode_date("2min ago")).to be_close(Time.utc - 2.minutes, 500.milliseconds)
      expect(decode_date("3h ago")).to be_close(Time.utc - 3.hours, 500.milliseconds)
      expect(decode_date("4d ago")).to be_close(Time.utc - 4.days, 500.milliseconds)
      expect(decode_date("5w ago")).to be_close(Time.utc - 5.weeks, 500.milliseconds)
      expect(decode_date("6mo ago")).to be_close(Time.utc - 6.months, 500.milliseconds)
      expect(decode_date("7y ago")).to be_close(Time.utc - 7.years, 500.milliseconds)
    end

    it "parses short dates (en-GB)" do
      expect(decode_date("55s ago")).to be_close(Time.utc - 55.seconds, 500.milliseconds)
      expect(decode_date("44min ago")).to be_close(Time.utc - 44.minutes, 500.milliseconds)
      expect(decode_date("22hr ago")).to be_close(Time.utc - 22.hours, 500.milliseconds)
      expect(decode_date("1day ago")).to be_close(Time.utc - 1.day, 500.milliseconds)
      expect(decode_date("2days ago")).to be_close(Time.utc - 2.days, 500.milliseconds)
      expect(decode_date("3wk ago")).to be_close(Time.utc - 3.weeks, 500.milliseconds)
      expect(decode_date("11mo ago")).to be_close(Time.utc - 11.months, 500.milliseconds)
      expect(decode_date("11yr ago")).to be_close(Time.utc - 11.years, 500.milliseconds)
    end

    it "parses long forms (singular)" do
      expect(decode_date("1 second ago")).to be_close(Time.utc - 1.second, 500.milliseconds)
      expect(decode_date("1 minute ago")).to be_close(Time.utc - 1.minute, 500.milliseconds)
      expect(decode_date("1 hour ago")).to be_close(Time.utc - 1.hour, 500.milliseconds)
      expect(decode_date("1 day ago")).to be_close(Time.utc - 1.day, 500.milliseconds)
      expect(decode_date("1 week ago")).to be_close(Time.utc - 1.week, 500.milliseconds)
      expect(decode_date("1 month ago")).to be_close(Time.utc - 1.month, 500.milliseconds)
      expect(decode_date("1 year ago")).to be_close(Time.utc - 1.year, 500.milliseconds)
    end

    it "parses long forms (plural)" do
      expect(decode_date("5 seconds ago")).to be_close(Time.utc - 5.seconds, 500.milliseconds)
      expect(decode_date("17 minutes ago")).to be_close(Time.utc - 17.minutes, 500.milliseconds)
      expect(decode_date("23 hours ago")).to be_close(Time.utc - 23.hours, 500.milliseconds)
      expect(decode_date("3 days ago")).to be_close(Time.utc - 3.days, 500.milliseconds)
      expect(decode_date("2 weeks ago")).to be_close(Time.utc - 2.weeks, 500.milliseconds)
      expect(decode_date("9 months ago")).to be_close(Time.utc - 9.months, 500.milliseconds)
      expect(decode_date("8 years ago")).to be_close(Time.utc - 8.years, 500.milliseconds)
    end
  end

  describe "rewrite_privacy_redirect_url" do
    it "leaves URLs unchanged when no privacy redirects are configured" do
      redirects = PrivacyRedirects.new
      expect(rewrite_privacy_redirect_url("https://www.reddit.com/r/crystal_lang", redirects)).to eq("https://www.reddit.com/r/crystal_lang")
      expect(rewrite_privacy_redirect_url("https://twitter.com/invidious", redirects)).to eq("https://twitter.com/invidious")
    end

    it "rewrites Reddit, Twitter/X, Instagram, Wikipedia, Medium, TikTok, Imgur, Fandom, Translate, Search, and Maps URLs when configured" do
      redirects = PrivacyRedirects.new(
        nitter: "https://nitter.net",
        reddit: "https://teddit.net",
        bibliogram: "https://bibliogram.art",
        wikiless: "https://wikiless.org",
        scribe: "https://scribe.rip",
        proxitok: "https://proxitok.pabloferreiro.es",
        rimgo: "https://rimgo.pussthecat.org",
        breezewiki: "https://breezewiki.com",
        simplytranslate: "https://simplytranslate.org",
        searx: "https://searx.be",
        openstreetmap: "https://www.openstreetmap.org"
      )

      expect(rewrite_privacy_redirect_url("https://www.reddit.com/r/invidious/comments/123/test?sort=top", redirects)).to eq("https://teddit.net/r/invidious/comments/123/test?sort=top")
      expect(rewrite_privacy_redirect_url("https://i.redd.it/abc123.png", redirects)).to eq("https://teddit.net/img/abc123.png")
      expect(rewrite_privacy_redirect_url("https://twitter.com/iv_org/status/123", redirects)).to eq("https://nitter.net/iv_org/status/123")
      expect(rewrite_privacy_redirect_url("https://x.com/iv_org/status/123", redirects)).to eq("https://nitter.net/iv_org/status/123")
      expect(rewrite_privacy_redirect_url("https://www.instagram.com/invidious", redirects)).to eq("https://bibliogram.art/u/invidious")
      expect(rewrite_privacy_redirect_url("https:// www.instagram.com/p/CXXX".gsub(" ", ""), redirects)).to eq("https://bibliogram.art/p/CXXX")
      expect(rewrite_privacy_redirect_url("https://en.wikipedia.org/wiki/Invidious", redirects)).to eq("https://wikiless.org/wiki/Invidious?lang=en")
      expect(rewrite_privacy_redirect_url("https://medium.com/@user/post-123", redirects)).to eq("https://scribe.rip/@user/post-123")
      expect(rewrite_privacy_redirect_url("https://www.tiktok.com/@user/video/123", redirects)).to eq("https://proxitok.pabloferreiro.es/@user/video/123")
      expect(rewrite_privacy_redirect_url("https://imgur.com/gallery/abc", redirects)).to eq("https://rimgo.pussthecat.org/gallery/abc")
      expect(rewrite_privacy_redirect_url("https://minecraft.fandom.com/wiki/Creeper", redirects)).to eq("https://breezewiki.com/minecraft/wiki/Creeper")
      expect(rewrite_privacy_redirect_url("https://translate.google.com/?sl=en&tl=fr&text=hello", redirects)).to eq("https://simplytranslate.org/?sl=en&tl=fr&text=hello")
      expect(rewrite_privacy_redirect_url("https://www.google.com/search?q=invidious", redirects)).to eq("https://searx.be/search?q=invidious")
      expect(rewrite_privacy_redirect_url("https://www.google.com/maps/place/Paris", redirects)).to eq("https://www.openstreetmap.org/maps/place/Paris")
    end

    it "rewrites YouTube /redirect links inside parse_link_endpoint" do
      redirects = PrivacyRedirects.new(reddit: "https://libreddit.spike.codes", nitter: "https://nitter.net")
      endpoint = JSON.parse(%({"urlEndpoint":{"url":"https://www.youtube.com/redirect?q=https%3A%2F%2Freddit.com%2Fr%2Fprivacy"}}))
      html = parse_link_endpoint(endpoint, "https://reddit.com/r/privacy", "dQw4w9WgXcQ", redirects)
      expect(html).to eq(%(<a href="https://libreddit.spike.codes/r/privacy">libreddit.spike.codes/r/privacy</a>))
    end
  end
end

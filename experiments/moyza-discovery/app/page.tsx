import { getAllSections } from "@/data";
import { BottomTabBar } from "@/components/BottomTabBar";
import { Logo } from "@/components/Logo";
import { PosterSection } from "@/components/PosterSection";
import { SearchBar } from "@/components/SearchBar";
import { SurveyBanner } from "@/components/SurveyBanner";

export default function HomePage() {
  const sections = getAllSections();

  return (
    <div className="app-shell">
      <header className="home-header">
        <div className="home-header__brand-row">
          <Logo />
          <button
            type="button"
            className="globe-btn"
            aria-label="Language"
            data-testid="globe-btn"
          >
            🌐
          </button>
        </div>
        <SearchBar />
        <SurveyBanner variant="home" />
      </header>
      <main className="home-main" data-testid="home-main">
        {sections.map((section) => (
          <PosterSection key={section.key} section={section} />
        ))}
      </main>
      <BottomTabBar />
    </div>
  );
}

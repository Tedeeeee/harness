import { notFound } from "next/navigation";
import { CastList } from "@/components/CastList";
import { DetailTabs } from "@/components/DetailTabs";
import { HeroSection } from "@/components/HeroSection";
import { SimilarSection } from "@/components/SimilarSection";
import { SynopsisPanel } from "@/components/SynopsisPanel";
import { WatchNowBar } from "@/components/WatchNowBar";
import { getTitleById } from "@/data/accessors";

export default async function TitleDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const title = getTitleById(id);
  if (!title) {
    notFound();
  }

  return (
    <div className="app-shell detail-shell">
      <HeroSection title={title} />
      <DetailTabs />
      <main className="detail-main" data-testid="detail-main">
        <SynopsisPanel title={title} />
        <CastList title={title} />
        <SimilarSection title={title} />
      </main>
      <WatchNowBar title={title} />
    </div>
  );
}

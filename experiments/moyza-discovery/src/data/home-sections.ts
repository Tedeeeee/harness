import type { HomeSection } from "./types";

export const HOME_SECTION_MAX_ITEMS = 6;

export const HOME_SECTIONS: readonly HomeSection[] = [
  {
    key: "new-releases",
    label: "업데이트된 신작",
    titleIds: ["t-08", "t-01", "t-13", "t-03", "t-05", "t-10"],
    maxItems: HOME_SECTION_MAX_ITEMS,
  },
  {
    key: "popular-picks",
    label: "인기작 픽",
    titleIds: ["t-01", "t-06", "t-08", "t-14", "t-13", "t-02"],
    maxItems: HOME_SECTION_MAX_ITEMS,
  },
  {
    key: "korea-picks",
    label: "코리아 픽",
    titleIds: ["t-01", "t-06", "t-08", "t-02", "t-04", "t-03"],
    maxItems: HOME_SECTION_MAX_ITEMS,
  },
];

# Movie Log

Personal movie review tracker. Record, browse, filter, and sort your movie watching history.

## Requirements

- Node.js 18+
- npm

## Setup

```bash
npm install
```

## Run

```bash
npm run dev
```

Open [http://localhost:3333](http://localhost:3333).

## Features

- Create movie reviews with title, rating (1-5 stars), short review, detailed review, and watched date
- Browse all reviews in a list
- Filter by rating range and watched date range
- Sort by date, rating, or title (ascending/descending)
- Edit and delete existing reviews
- Responsive layout for mobile browsers

## Tech Stack

- Next.js (App Router)
- SQLite via better-sqlite3
- Tailwind CSS
- TypeScript

## Tests

```bash
npm test
```

Runs API and data layer unit tests with Vitest.

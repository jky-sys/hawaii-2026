# Hawaii 2026

A lightweight static trip tracker for the Hawaii 2026 itinerary.

Open `index.html` locally or deploy it with GitHub Pages.

## Supabase cloud sync

The app is prepared for Supabase sync:

1. Create a Supabase project.
2. Run `supabase_schema.sql` in the SQL Editor.
3. Copy the Project URL and anon public key from Project Settings > API.
4. Paste them into `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `index.html`.
5. Commit and push to GitHub Pages.

Photos upload to the public `hawaii-trip-photos` Storage bucket. The access code still protects the UI, but this is a lightweight shared-trip setup rather than a high-security private vault.

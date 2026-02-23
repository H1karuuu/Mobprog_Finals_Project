# personalprofile_webprogfinals

Flutter app backed by Supabase.

## Supabase Setup (Required for Image Upload)

1. Open Supabase Dashboard for your project.
2. Go to `SQL Editor`.
3. Run `supabase_setup.sql` from this project root.

This creates:
- Required tables (`profiles`, `posts`, `friends`, `gallery`)
- Storage buckets (`avatars`, `covers`, `posts`, `friends`, `gallery`)
- RLS policies so authenticated users can upload their own files

Without these policies, gallery/post/friend image uploads can fail silently.

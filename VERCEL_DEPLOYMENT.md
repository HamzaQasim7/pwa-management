# Vercel Deployment Guide for Flutter Web App

## Problem
Vercel shows 404 error when deploying Flutter web apps because:
1. Vercel doesn't have Flutter SDK installed by default
2. Build output directory needs proper configuration
3. Flutter web uses client-side routing that needs special handling

## Solution

### Option 1: Automatic Build (Recommended)
The project now includes:
- `vercel.json` - Vercel configuration
- `package.json` - Build scripts
- `build.sh` - Flutter build script

**Steps:**
1. Push these files to your Git repository
2. Connect your repo to Vercel
3. Vercel will automatically:
   - Install Flutter SDK during build
   - Run `flutter build web --release`
   - Deploy from `build/web` directory

### Option 2: Manual Build (Faster)
If automatic build is too slow, you can build locally:

```bash
# Build the Flutter web app
flutter build web --release --base-href /

# The build output will be in build/web/
```

Then in Vercel dashboard:
1. Go to Project Settings → General
2. Set **Output Directory** to: `build/web`
3. Set **Build Command** to: `echo "Using pre-built files"`
4. Deploy

### Option 3: GitHub Actions (Best for CI/CD)
Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Vercel
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      - run: flutter pub get
      - run: flutter build web --release --base-href /
      - uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
          working-directory: ./
```

## Vercel Configuration

The `vercel.json` file includes:
- **Build Command**: `flutter build web --release`
- **Output Directory**: `build/web`
- **Rewrites**: All routes redirect to `index.html` (for Flutter routing)
- **Headers**: Proper caching and security headers

## Troubleshooting

### 404 Error
- Check that `vercel.json` has correct `outputDirectory`
- Verify `build/web` folder exists after build
- Check that `rewrites` rule is present

### Build Fails
- Ensure Flutter SDK is available (or use manual build)
- Check that all dependencies are in `pubspec.yaml`
- Verify Firebase configuration is correct

### Routing Issues
- Flutter web uses client-side routing
- All routes must redirect to `index.html`
- The `rewrites` rule in `vercel.json` handles this

## Current Configuration

✅ `vercel.json` - Configured
✅ `package.json` - Build scripts added
✅ `build.sh` - Flutter build script
✅ Routing - All routes redirect to index.html

## Next Steps

1. **Commit and push** these files:
   ```bash
   git add vercel.json package.json build.sh
   git commit -m "Add Vercel deployment configuration"
   git push
   ```

2. **In Vercel Dashboard**:
   - Go to your project
   - Settings → General
   - Verify:
     - Framework Preset: Other
     - Build Command: (leave empty, uses package.json)
     - Output Directory: `build/web`
     - Install Command: (leave empty)

3. **Redeploy** your project

## Notes

- First build may take 5-10 minutes (Flutter SDK installation)
- Subsequent builds are faster (cached Flutter SDK)
- For faster builds, use Option 2 (manual build) or Option 3 (GitHub Actions)


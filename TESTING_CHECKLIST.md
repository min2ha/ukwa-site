# Decap CMS Integration - Testing Checklist

This checklist will help you verify that the Decap CMS integration is working correctly.

## Pre-Testing Requirements

- [ ] Docker is installed and running
- [ ] Node.js 18+ is installed (for npx)
- [ ] Git repository is clean (no uncommitted changes)
- [ ] You have read [CMS_INTEGRATION_README.md](CMS_INTEGRATION_README.md)

---

## Phase 1: Configuration Validation

### 1.1 YAML Configuration
```bash
npx js-yaml static/admin/config.yml
```
- [ ] Command runs without errors
- [ ] Output shows valid JSON structure
- [ ] `publish_mode: editorial_workflow` is present
- [ ] `local_backend: true` is present

### 1.2 Docker Compose Configuration
```bash
docker compose -f docker-compose-integrated.cms.yml config
```
- [ ] Command runs without errors
- [ ] Shows 4 services: site, hugo-dev, git-gateway, auth-proxy
- [ ] All ports are mapped correctly (1080, 1313, 8081, 8082)

### 1.3 File Structure
- [ ] `static/admin/config.yml` exists
- [ ] `static/admin/index.html` exists
- [ ] `cms-config/users/` directory exists with 3 JSON files
- [ ] `cms-config/nginx.conf` exists
- [ ] `docker-compose-integrated.cms.yml` exists
- [ ] `start-cms-local.sh` is executable
- [ ] `stop-cms-local.sh` is executable

---

## Phase 2: Local Development Environment

### 2.1 Start Services

**Using startup script:**
```bash
./start-cms-local.sh
```

**Expected output:**
- [ ] "Starting services..." message appears
- [ ] Docker containers start successfully
- [ ] Access points are displayed
- [ ] No error messages

**Verify containers:**
```bash
docker ps | grep ukwa-site-original
```
- [ ] 4 containers are running
- [ ] hugo-dev container is running
- [ ] git-gateway container is running
- [ ] auth-proxy container is running
- [ ] site container is running

### 2.2 Check Service Endpoints

**Test Hugo development server:**
```bash
curl -I http://localhost:1313
```
- [ ] Returns HTTP 200 OK
- [ ] Page loads in browser

**Test CMS admin interface:**
```bash
curl -I http://localhost:1313/admin/
```
- [ ] Returns HTTP 200 OK
- [ ] Opens in browser without errors

**Test Git Gateway:**
```bash
curl http://localhost:8081/health
```
- [ ] Returns health status (may need to wait for npm install to complete)

**Test Auth Proxy:**
```bash
curl http://localhost:8082/health
```
- [ ] Returns `{"status":"ok"}`

**View user configurations:**
```bash
curl http://localhost:8082/users/
```
- [ ] Returns JSON list of user files

---

## Phase 3: CMS Interface Testing

### 3.1 Access CMS
1. Open browser to `http://localhost:1313/admin/`

**Checklist:**
- [ ] CMS interface loads (Decap CMS logo appears)
- [ ] No console errors (press F12 to check)
- [ ] "Working with Local Repository" message appears (if using local backend)
- [ ] Collections appear in left sidebar

### 3.2 Navigate Collections
1. Click "Collections" in sidebar

**Checklist:**
- [ ] "Homepage" collection is visible
- [ ] "Information Pages" collection is visible
- [ ] Click on "Information Pages"
- [ ] List of pages appears (About, FAQ, etc.)

### 3.3 View Existing Content
1. Click on "About Us" or any info page

**Checklist:**
- [ ] Content editor opens
- [ ] Title field shows current title
- [ ] Body field shows current markdown content
- [ ] Language tabs appear (EN, CY, GD)
- [ ] Rich text editor toolbar is visible

---

## Phase 4: Content Editing

### 4.1 Edit Existing Content
1. Open "About Us" page in CMS
2. Make a small edit (e.g., add "TEST" at the end of title)
3. Click "Save"

**Checklist:**
- [ ] "Save" button is visible
- [ ] No error messages appear
- [ ] Success notification appears
- [ ] File is updated in repository

**Verify file changed:**
```bash
git diff content/info/about/index.en.md
```
- [ ] Shows your changes
- [ ] Changes are as expected

**Revert test changes:**
```bash
git checkout content/info/about/index.en.md
```

### 4.2 Switch Languages
1. Open any content page
2. Click language tabs (EN → CY → GD)

**Checklist:**
- [ ] Can switch between languages
- [ ] Each language shows different content
- [ ] No errors when switching
- [ ] Content persists when switching back

### 4.3 Rich Text Editing
1. Open content editor
2. Test formatting options:
   - Bold text (select text, click **B**)
   - Italic text (select text, click *I*)
   - Create heading (use heading dropdown)
   - Add link (click link icon)
   - Add image (click image icon)

**Checklist:**
- [ ] Bold formatting works
- [ ] Italic formatting works
- [ ] Headings can be created
- [ ] Link dialog opens
- [ ] Image dialog opens

---

## Phase 5: Media Management

### 5.1 Access Media Library
1. In CMS, look for "Media" in sidebar
2. Or click image icon while editing content

**Checklist:**
- [ ] Media library opens
- [ ] Existing images are visible (if any)
- [ ] "Upload" button is visible

### 5.2 Upload Test Image
1. Click "Upload"
2. Select a small test image (< 1 MB)
3. Wait for upload

**Checklist:**
- [ ] Upload dialog appears
- [ ] Can select file
- [ ] Upload progress shows
- [ ] Image appears in media library
- [ ] File created in `static/assets/images/uploads/`

**Verify file:**
```bash
ls -lh static/assets/images/uploads/
```
- [ ] Test image file is present

**Clean up:**
```bash
rm static/assets/images/uploads/[your-test-image]
```

---

## Phase 6: Editorial Workflow

### 6.1 Understand Workflow States
1. Look for "Workflow" in sidebar

**Checklist:**
- [ ] "Workflow" section is visible
- [ ] Shows three columns: "Drafts", "In Review", "Ready"
- [ ] (Initially empty if no content in workflow)

### 6.2 Create Draft Content
1. Go to Collections → Information Pages
2. Try to create new page (if create is enabled)
   - Note: Current config has `create: false` for info pages
3. Instead, edit existing content and change status

**Checklist:**
- [ ] Can see workflow status options
- [ ] Can change status (if permissions allow)

### 6.3 Test Workflow Transitions
**Note:** Full workflow testing requires:
- Git Gateway connected to GitHub
- Multiple user accounts
- Pull request permissions

**For local testing:**
- [ ] Understand that local backend bypasses workflow
- [ ] Changes are direct to filesystem
- [ ] Production will use Git PRs for workflow

---

## Phase 7: Multi-language Support

### 7.1 Test Language Switching
1. Open any page with multi-language support
2. Switch between EN, CY, and GD tabs

**Checklist:**
- [ ] All three language tabs appear
- [ ] Content differs per language
- [ ] Can edit each language independently
- [ ] Saving works for all languages

### 7.2 Verify Language Files
```bash
ls content/info/about/
```

**Checklist:**
- [ ] `index.en.md` exists
- [ ] `index.cy.md` exists
- [ ] `index.gd.md` exists
- [ ] Each file has correct language content

---

## Phase 8: Preview Functionality

### 8.1 Live Preview
1. Open content editor
2. Make a change
3. Look for preview pane (usually right side)

**Checklist:**
- [ ] Preview pane is visible (if configured)
- [ ] Changes appear in preview
- [ ] Or: Changes appear in Hugo dev server at localhost:1313

### 8.2 Hugo Live Reload
1. Make a change in CMS
2. Save the content
3. Check Hugo dev server at `http://localhost:1313`

**Checklist:**
- [ ] Page reloads automatically
- [ ] Changes are visible on the site
- [ ] No build errors

---

## Phase 9: Error Handling

### 9.1 Test Invalid Input
1. Try to leave required field empty
2. Try to upload very large file (> 10 MB)
3. Try invalid characters in fields

**Checklist:**
- [ ] Validation errors appear
- [ ] Error messages are clear
- [ ] Cannot save invalid data
- [ ] CMS doesn't crash

### 9.2 Network Issues
1. Stop git-gateway container:
   ```bash
   docker stop $(docker ps -q -f name=git-gateway)
   ```
2. Try to save content

**Checklist:**
- [ ] Error message appears (if using backend)
- [ ] Local backend still works (saves to filesystem)

**Restart container:**
```bash
docker start $(docker ps -aq -f name=git-gateway)
```

---

## Phase 10: Performance

### 10.1 Load Time
1. Open CMS admin interface
2. Note load time

**Checklist:**
- [ ] CMS loads in < 5 seconds
- [ ] No excessive lag
- [ ] Interface is responsive

### 10.2 Save Time
1. Make edit
2. Click save
3. Note save time

**Checklist:**
- [ ] Save completes in < 2 seconds (local)
- [ ] No timeout errors
- [ ] Success message appears

---

## Phase 11: Browser Compatibility

### 11.1 Test in Multiple Browsers
Test CMS in:
- [ ] Chrome/Chromium
- [ ] Firefox
- [ ] Safari (if on Mac)
- [ ] Edge

**For each browser:**
- [ ] CMS loads correctly
- [ ] Can edit content
- [ ] Can save changes
- [ ] No console errors

### 11.2 Mobile Testing (Optional)
Open CMS on mobile device:

**Checklist:**
- [ ] CMS loads (may be cramped)
- [ ] Can navigate
- [ ] Can make basic edits
- [ ] Note: Mobile is not primary interface

---

## Phase 12: Documentation

### 12.1 User Guide
1. Open `docs/USER_GUIDE.md`

**Checklist:**
- [ ] File exists and opens
- [ ] Table of contents is present
- [ ] All sections are complete
- [ ] Examples are clear
- [ ] Troubleshooting section is helpful

### 12.2 DevOps Guide
1. Open `docs/DEVOPS_GUIDE.md`

**Checklist:**
- [ ] File exists and opens
- [ ] Architecture diagrams are clear
- [ ] Setup instructions are complete
- [ ] Security section is thorough
- [ ] Troubleshooting is comprehensive

### 12.3 README Files
- [ ] `CMS_INTEGRATION_README.md` is clear
- [ ] `IMPLEMENTATION_SUMMARY.md` is complete
- [ ] `cms-config/users/README.md` explains roles

---

## Phase 13: Git Integration

### 13.1 Check Git Status
```bash
git status
```

**Checklist:**
- [ ] Shows modified files (if you made edits)
- [ ] No unexpected changes
- [ ] Working tree is clean (or shows expected changes)

### 13.2 Review Changes
```bash
git diff
```

**Checklist:**
- [ ] Changes are as expected
- [ ] No extra modifications
- [ ] Content looks correct

### 13.3 Commit Test Changes
```bash
git add .
git commit -m "Test: Decap CMS integration testing"
```

**Checklist:**
- [ ] Commit succeeds
- [ ] All files are committed
- [ ] Commit message is clear

**Revert if needed:**
```bash
git reset --soft HEAD~1
```

---

## Phase 14: Cleanup and Shutdown

### 14.1 Stop Services
```bash
./stop-cms-local.sh
```

**Checklist:**
- [ ] Script runs successfully
- [ ] "All services stopped" message appears
- [ ] No error messages

### 14.2 Verify Shutdown
```bash
docker ps | grep ukwa-site-original
```

**Checklist:**
- [ ] No containers are running
- [ ] All services stopped cleanly

### 14.3 Cleanup Test Data
```bash
# Remove test images
rm -f static/assets/images/uploads/test-*

# Reset any test content changes
git checkout content/
```

**Checklist:**
- [ ] Test files removed
- [ ] Repository is clean
- [ ] Ready for production setup

---

## Phase 15: Production Readiness

### 15.1 Configuration Review
Review `static/admin/config.yml`:

**Checklist:**
- [ ] `backend.name` is set correctly
- [ ] `backend.repo` points to correct repository
- [ ] `backend.branch` is correct (master)
- [ ] `publish_mode: editorial_workflow` is present
- [ ] For production: `local_backend` should be false or removed

### 15.2 Security Review
- [ ] OAuth credentials are not in repository
- [ ] Sensitive data is in environment variables
- [ ] `.gitignore` covers sensitive files
- [ ] HTTPS will be used in production
- [ ] Branch protection rules are planned

### 15.3 Deployment Plan
- [ ] Production platform chosen (Netlify/GitHub/Azure)
- [ ] Authentication method decided
- [ ] User management plan in place
- [ ] CI/CD pipeline designed
- [ ] Backup strategy defined

---

## Testing Summary

### Pass Criteria

**Minimum requirements to pass:**
- ✅ CMS loads without errors
- ✅ Can view existing content
- ✅ Can edit and save content
- ✅ Changes appear in git
- ✅ Multi-language support works
- ✅ Media upload functions
- ✅ Documentation is complete

**Optional (for full pass):**
- ✅ Workflow stages function
- ✅ Multiple browsers tested
- ✅ Performance is acceptable
- ✅ User roles are understood
- ✅ Production plan is ready

### Results Template

Copy and fill this out:

```
DECAP CMS INTEGRATION TEST RESULTS
===================================
Date: ___________
Tester: ___________

Phase 1 - Configuration:        [ ] Pass  [ ] Fail
Phase 2 - Local Environment:    [ ] Pass  [ ] Fail
Phase 3 - CMS Interface:        [ ] Pass  [ ] Fail
Phase 4 - Content Editing:      [ ] Pass  [ ] Fail
Phase 5 - Media Management:     [ ] Pass  [ ] Fail
Phase 6 - Editorial Workflow:   [ ] Pass  [ ] Fail
Phase 7 - Multi-language:       [ ] Pass  [ ] Fail
Phase 8 - Preview:              [ ] Pass  [ ] Fail
Phase 9 - Error Handling:       [ ] Pass  [ ] Fail
Phase 10 - Performance:         [ ] Pass  [ ] Fail
Phase 11 - Browser Compat:      [ ] Pass  [ ] Fail
Phase 12 - Documentation:       [ ] Pass  [ ] Fail
Phase 13 - Git Integration:     [ ] Pass  [ ] Fail
Phase 14 - Cleanup:             [ ] Pass  [ ] Fail
Phase 15 - Prod Readiness:      [ ] Pass  [ ] Fail

Overall Result: [ ] PASS  [ ] FAIL  [ ] PARTIAL

Issues Found:
1. ___________________________________________
2. ___________________________________________
3. ___________________________________________

Recommendations:
1. ___________________________________________
2. ___________________________________________
3. ___________________________________________

Ready for Production: [ ] YES  [ ] NO  [ ] WITH CHANGES

Notes:
____________________________________________________
____________________________________________________
____________________________________________________
```

---

## Troubleshooting During Testing

### CMS Won't Load
1. Check Hugo is running: `curl http://localhost:1313`
2. Check browser console for errors (F12)
3. Verify config.yml syntax: `npx js-yaml static/admin/config.yml`
4. Restart Hugo: `docker compose -f docker-compose-integrated.cms.yml restart hugo-dev`

### Can't Save Content
1. Check decap-server is running: `docker ps | grep git-gateway`
2. Check file permissions: `ls -la content/info/`
3. Verify you're using local backend: Check config.yml
4. Check console for error messages

### Docker Issues
1. Check Docker is running: `docker info`
2. Check for port conflicts: `lsof -i :1313,8081,8082`
3. View logs: `docker compose -f docker-compose-integrated.cms.yml logs`
4. Restart services: `./stop-cms-local.sh && ./start-cms-local.sh`

### Changes Not Appearing
1. Check file was actually saved: `git status`
2. View file content: `cat content/info/about/index.en.md`
3. Check Hugo console for build errors
4. Hard refresh browser: Cmd+Shift+R (Mac) or Ctrl+F5 (Windows)

---

## Post-Testing Actions

### If All Tests Pass
1. ✅ Document test results
2. ✅ Archive test artifacts
3. ✅ Proceed to production setup
4. ✅ Schedule user training
5. ✅ Plan deployment

### If Tests Fail
1. ❌ Document failures in detail
2. ❌ Review error messages
3. ❌ Check documentation for solutions
4. ❌ Create GitHub issue if needed
5. ❌ Fix issues and re-test

### If Partial Pass
1. ⚠️ Document what works and what doesn't
2. ⚠️ Prioritize critical issues
3. ⚠️ Create action plan
4. ⚠️ Re-test after fixes
5. ⚠️ Decide if production-ready

---

## Additional Resources

- **Quick Start:** [CMS_INTEGRATION_README.md](CMS_INTEGRATION_README.md)
- **User Guide:** [docs/USER_GUIDE.md](docs/USER_GUIDE.md)
- **DevOps Guide:** [docs/DEVOPS_GUIDE.md](docs/DEVOPS_GUIDE.md)
- **Implementation Summary:** [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)

---

**Checklist Version:** 1.0
**Last Updated:** 2025-01-28
**Status:** Ready for use

Good luck with testing! 🚀

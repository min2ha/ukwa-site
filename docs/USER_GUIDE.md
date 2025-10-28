# Decap CMS User Guide for UKWA Website
## A Non-Technical Guide to Content Management

---

## Table of Contents
1. [Introduction](#introduction)
2. [User Roles and Permissions](#user-roles-and-permissions)
3. [Accessing the CMS](#accessing-the-cms)
4. [Understanding the Workflow](#understanding-the-workflow)
5. [Creating and Editing Content](#creating-and-editing-content)
6. [Working with Media](#working-with-media)
7. [The Editorial Workflow Process](#the-editorial-workflow-process)
8. [Common Tasks](#common-tasks)
9. [Troubleshooting](#troubleshooting)

---

## Introduction

Welcome to the UKWA Content Management System (CMS)! This guide will help you manage content on the UK Web Archive website without needing technical knowledge.

### What is Decap CMS?

Decap CMS is a modern, user-friendly content management system that allows you to:
- Edit website content through a simple web interface
- Preview changes before publishing
- Collaborate with team members
- Maintain version history of all changes

---

## User Roles and Permissions

The UKWA CMS has three user roles, each with different capabilities:

### 1. **Supervisor (Administrator)**
**Who should have this role:** Senior staff, content managers, site administrators

**What you can do:**
- ✅ Create, edit, and delete content
- ✅ Upload and delete media files
- ✅ Approve content submitted by editors
- ✅ Publish content to the live website
- ✅ Unpublish content if needed
- ✅ Manage user access
- ✅ Override workflow decisions

**Use this role for:** Final approval and publishing of content

---

### 2. **Editor (Content Creator)**
**Who should have this role:** Content writers, translators, regular contributors

**What you can do:**
- ✅ Create and edit content
- ✅ Upload media files (images, documents)
- ✅ Submit content for review
- ✅ Edit your own drafts
- ✅ View all published content
- ❌ Cannot publish content directly
- ❌ Cannot delete content or media
- ❌ Cannot manage users

**Use this role for:** Creating and preparing content for publication

---

### 3. **Viewer (Observer)**
**Who should have this role:** Reviewers, stakeholders, external consultants

**What you can do:**
- ✅ View all content (published and drafts)
- ✅ See the status of content in workflow
- ✅ Comment on content (if enabled)
- ❌ Cannot create or edit content
- ❌ Cannot upload files
- ❌ Cannot approve or publish

**Use this role for:** Reviewing content without making changes

---

## Accessing the CMS

### For Production (Live Website)

1. **Navigate to:** `https://www.webarchive.org.uk/admin/`
2. **Login:** Use your GitHub or organizational credentials
3. **First-time setup:** You'll receive an invitation email to access the CMS

### For Local Development (Testing)

1. **Start the system:** Your DevOps team will provide instructions
2. **Navigate to:** `http://localhost:1313/admin/`
3. **Login:** Use your test credentials:
   - Supervisor: `supervisor@ukwa-local.test`
   - Editor: `editor@ukwa-local.test`
   - Viewer: `viewer@ukwa-local.test`

---

## Understanding the Workflow

The CMS uses an **Editorial Workflow** to ensure quality control. Think of it like a document approval process in an office.

### Workflow States

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   DRAFT     │ --> │  IN REVIEW  │ --> │  PUBLISHED  │
│  (Editor)   │     │ (Supervisor)│     │ (Supervisor)│
└─────────────┘     └─────────────┘     └─────────────┘
      ↓                    ↓
 [Save Draft]        [Request Review]      [Publish]
```

### 1. **Draft Stage**
- **Who:** Editors create content here
- **What:** Content is being written and edited
- **Visibility:** Only visible to CMS users, not on live site
- **Actions:**
  - Save progress
  - Continue editing
  - Request review when ready

### 2. **In Review Stage**
- **Who:** Supervisor reviews the content
- **What:** Content is being checked for accuracy and quality
- **Visibility:** Visible to all CMS users, not on live site
- **Actions:**
  - Approve (move to ready for publishing)
  - Request changes (send back to editor with notes)
  - Reject (if content is not suitable)

### 3. **Ready to Publish**
- **Who:** Supervisor makes final decision
- **What:** Content approved and waiting for publication
- **Actions:**
  - Publish (makes content live on website)
  - Send back for final tweaks

### 4. **Published**
- **What:** Content is live on the website
- **Visibility:** Public - everyone can see it
- **Actions:**
  - Unpublish (remove from live site)
  - Edit (creates a new draft version)

---

## Creating and Editing Content

### Creating New Content (Editors and Supervisors)

1. **Navigate to Collections:**
   - Click "Collections" in the sidebar
   - Choose the type of content (e.g., "Information Pages", "Homepage")

2. **Create New Entry:**
   - Click "New Information Page" (or relevant content type)
   - You'll see a form with fields to fill in

3. **Fill in the Content:**
   - **Title:** Enter a clear, descriptive title
   - **Body:** Write your content using the rich text editor
   - **Language:** Select or switch between English, Welsh (Cymraeg), or Gaelic (Gàidhlig)

4. **Using the Rich Text Editor:**
   - **Bold text:** Select text and click **B**
   - **Italic text:** Select text and click *I*
   - **Headings:** Use the dropdown to select heading levels
   - **Links:**
     - Select text
     - Click the link icon
     - Enter the URL
   - **Images:**
     - Click where you want the image
     - Click the image icon
     - Upload or select from media library

5. **Save Your Work:**
   - Click "Save" to save as draft
   - Content is automatically saved as you work

### Editing Existing Content

1. **Find the Content:**
   - Navigate to "Collections"
   - Browse or search for the page
   - Click on the entry

2. **Make Changes:**
   - Edit any field
   - The system tracks all changes

3. **Save:**
   - Click "Save" to update the draft

### Multi-language Content

The UKWA site supports three languages. When editing content:

1. **Switch Languages:**
   - Look for language tabs at the top of the editor
   - Click **EN** (English), **CY** (Welsh), or **GD** (Gaelic)

2. **Translate Content:**
   - Each language has its own fields
   - Translate titles and body text appropriately
   - Some fields (like IDs) are shared across languages

---

## Working with Media

### Uploading Images or Files

1. **Access Media Library:**
   - Click "Media" in the sidebar
   - Or click the image icon when editing content

2. **Upload New Files:**
   - Click "Upload"
   - Select files from your computer
   - Wait for upload to complete

3. **Insert into Content:**
   - Click the uploaded image
   - Click "Choose Selected"
   - The image will be inserted

4. **Image Best Practices:**
   - ✅ Use descriptive filenames (e.g., `british-library-reading-room.jpg`)
   - ✅ Optimize images before uploading (max 1-2 MB)
   - ✅ Use web-friendly formats: JPG, PNG, or WebP
   - ❌ Avoid very large files (slow page loading)
   - ❌ Don't use spaces in filenames

### Managing Media (Supervisors Only)

- **Delete files:** Select file and click delete icon
- **Organize:** Media is stored in `/assets/images/uploads/`

---

## The Editorial Workflow Process

### For Editors: Creating and Submitting Content

**Step 1: Create Content**
```
You write content → Save as Draft → Continue editing until ready
```

**Step 2: Request Review**
```
Content ready → Change status to "In Review" → Supervisor is notified
```

**Step 3: Respond to Feedback**
```
Supervisor requests changes → You edit content → Re-submit for review
```

**What to expect:**
- ⏱️ Review time: Usually 1-3 business days
- 📧 Notifications: You'll receive emails about status changes
- ♻️ Iterations: Content may go through multiple review cycles

---

### For Supervisors: Reviewing and Publishing

**Step 1: Review Queue**
```
Check "Workflow" section → See all content "In Review"
```

**Step 2: Review Content**
```
Read content → Check quality, accuracy, formatting
```

**Step 3: Decision**

**Option A - Approve:**
```
Content looks good → Set status to "Ready" → Click "Publish"
```

**Option B - Request Changes:**
```
Issues found → Add comments → Set status back to "Draft" → Notify editor
```

**Option C - Reject:**
```
Content not suitable → Add explanation → Reject entry
```

---

## Common Tasks

### Task 1: Update the "About Us" Page

1. Go to "Collections" → "Information Pages"
2. Find "About Us"
3. Click to open
4. Make your edits
5. Save
6. If you're an Editor: Change status to "In Review"
7. If you're a Supervisor: Review and click "Publish"

---

### Task 2: Add a New FAQ Entry

1. Go to "Collections" → "Information Pages"
2. Click "New Information Page"
3. Enter title: "Your Question Here"
4. Write the answer in the body
5. Set the correct language
6. Save as draft
7. Request review (Editors) or Publish (Supervisors)

---

### Task 3: Update an Image

1. Go to the page with the image
2. Click on the image in the editor
3. Delete the old image
4. Click image icon to upload new one
5. Select and upload file
6. Adjust alt text (description for accessibility)
7. Save

---

### Task 4: Translate a Page

1. Open the page you want to translate
2. Click the language tab (CY for Welsh, GD for Gaelic)
3. Enter translated title
4. Enter translated body text
5. Save
6. Request review or publish

---

## Troubleshooting

### Problem: "I can't log in"

**Solutions:**
- ✅ Check your email for invitation link
- ✅ Verify you're using the correct URL
- ✅ Contact your administrator to verify your access
- ✅ Try clearing browser cache and cookies

---

### Problem: "I can't see the Publish button"

**Reason:** You likely have an Editor or Viewer role

**Solution:**
- Request a Supervisor to review and publish your content
- Contact administrator if you need different permissions

---

### Problem: "My changes aren't showing on the website"

**Check:**
1. Did you click "Publish"? (Saving creates a draft only)
2. Wait 2-3 minutes for the site to rebuild
3. Try refreshing the page (Ctrl+F5 or Cmd+Shift+R)
4. Clear your browser cache

---

### Problem: "I accidentally deleted something"

**Solution:**
- Content is version-controlled through Git
- Contact your DevOps team to restore previous versions
- They can recover deleted content from version history

---

### Problem: "The editor is frozen or not responding"

**Solutions:**
1. Save your work if possible
2. Refresh the page
3. Try a different browser (Chrome or Firefox recommended)
4. Clear browser cache
5. Contact technical support if problem persists

---

### Problem: "I can't upload an image"

**Check:**
- File size (should be under 5 MB)
- File format (use JPG, PNG, or WebP)
- File name (no special characters or spaces)
- Your user role (Viewers cannot upload)

---

## Best Practices

### Writing Content

✅ **Do:**
- Write clearly and concisely
- Use proper headings for structure
- Add alt text to images (describes image for accessibility)
- Preview before publishing
- Check all language versions

❌ **Don't:**
- Copy/paste from Word (formatting issues) - use plain text first
- Use very long paragraphs
- Forget to save your work
- Publish without review (unless you're a Supervisor)

---

### Collaboration

✅ **Do:**
- Communicate with team members about content changes
- Leave clear comments when requesting changes
- Respond promptly to review requests
- Keep drafts organized

❌ **Don't:**
- Edit content someone else is working on without coordination
- Ignore review feedback
- Publish content without proper review

---

## Getting Help

### For Content Questions
- **Contact:** Your content manager or supervisor
- **Email:** [Your organization's content team email]

### For Technical Issues
- **Contact:** DevOps team
- **Email:** [Your organization's technical support email]
- **Documentation:** See `docs/DEVOPS_GUIDE.md`

### For User Access
- **Contact:** Your administrator
- **Request:** User account creation, permission changes, password resets

---

## Quick Reference Card

| **I want to...**              | **Steps**                                    | **Role Required** |
|-------------------------------|----------------------------------------------|-------------------|
| Create new content            | Collections → New → Fill form → Save        | Editor+           |
| Edit existing content         | Collections → Find item → Edit → Save       | Editor+           |
| Submit for review             | Edit → Change status to "In Review"         | Editor+           |
| Approve content               | Workflow → Review → Approve                 | Supervisor        |
| Publish content               | Workflow → Ready → Publish                  | Supervisor        |
| Upload an image               | Media → Upload → Select file                | Editor+           |
| Translate a page              | Edit → Switch language tab → Translate      | Editor+           |
| View content status           | Workflow → See all stages                   | Viewer+           |

---

## Glossary

- **CMS:** Content Management System - the software for managing website content
- **Draft:** Unpublished content being worked on
- **Editorial Workflow:** The process of creating, reviewing, and publishing content
- **Media Library:** Storage for images and files
- **Collection:** A group of similar content items (e.g., all info pages)
- **Markdown:** A simple formatting language for text
- **Alt Text:** Description of an image for accessibility
- **Slug:** URL-friendly version of a title
- **Front Matter:** Metadata about a content item (title, date, etc.)
- **i18n:** Internationalization - supporting multiple languages

---

**Document Version:** 1.0
**Last Updated:** 2025-01-28
**Maintained by:** UKWA DevOps Team

---

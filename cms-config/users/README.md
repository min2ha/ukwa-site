# User Roles Configuration for Decap CMS

This directory contains user role definitions for local development and testing of Decap CMS.

## User Accounts

### 1. Supervisor (Admin)
- **Username:** supervisor
- **Email:** supervisor@ukwa-local.test
- **Password:** (set during local authentication)
- **Capabilities:**
  - Full content management (create, edit, delete, publish)
  - Workflow management (approve, reject, publish)
  - Media library management
  - User management
  - Complete site administration

### 2. Editor
- **Username:** editor
- **Email:** editor@ukwa-local.test
- **Password:** (set during local authentication)
- **Capabilities:**
  - Create and edit content
  - Upload media files
  - Submit content for review
  - Cannot publish or delete content
  - Cannot manage users

### 3. Viewer
- **Username:** viewer
- **Email:** viewer@ukwa-local.test
- **Password:** (set during local authentication)
- **Capabilities:**
  - Read-only access to all content
  - View workflow status
  - Cannot create, edit, or delete content
  - Cannot upload media

## Local Development Authentication

For local development, you can use these test credentials:
- **All users:** Password: `test123` (configurable in your local environment)

## Production Configuration

In production with GitHub/GitLab:
1. Users are authenticated via OAuth through GitHub/GitLab
2. Permissions are managed through repository collaborator settings
3. Workflow stages are controlled via branch protections
4. These JSON files are for local development reference only

# UKWA Website - Decap CMS Integration

## 🎉 Integration Complete!

This repository now includes a complete Decap CMS (formerly Netlify CMS) integration for managing the UKWA Hugo static website content.

---

## 🚀 Quick Start

### Start the CMS locally:
```bash
./start-cms-local.sh
```

### Access the CMS:
Open your browser to: **http://localhost:1313/admin/**

### Stop when done:
```bash
./stop-cms-local.sh
```

---

## 📖 Documentation

### Start Here
- **[CMS_INTEGRATION_README.md](CMS_INTEGRATION_README.md)** - Quick start and overview

### For Content Editors
- **[docs/USER_GUIDE.md](docs/USER_GUIDE.md)** - Complete guide for non-technical users (7,000+ words)
  - User roles and permissions
  - How to create and edit content
  - Editorial workflow explained
  - Multi-language support
  - Media management
  - Troubleshooting

### For DevOps/Technical Teams
- **[docs/DEVOPS_GUIDE.md](docs/DEVOPS_GUIDE.md)** - Technical implementation guide (12,000+ words)
  - Architecture overview
  - Local development setup
  - Production deployment (Netlify, GitHub, Azure)
  - Git Gateway configuration
  - Security best practices
  - CI/CD integration
  - Monitoring and maintenance

### Testing & Implementation
- **[TESTING_CHECKLIST.md](TESTING_CHECKLIST.md)** - 15-phase testing guide
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Complete implementation overview
- **[FILES_CREATED.md](FILES_CREATED.md)** - Inventory of all changes

---

## 👥 User Roles

Three user roles are configured with different permissions:

| Role | Create | Edit | Delete | Publish | Approve |
|------|--------|------|--------|---------|---------|
| **Supervisor** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Editor** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Viewer** | ❌ | ❌ | ❌ | ❌ | ❌ |

### Local Test Credentials
- Supervisor: `supervisor@ukwa-local.test`
- Editor: `editor@ukwa-local.test`
- Viewer: `viewer@ukwa-local.test`

---

## 🔄 Editorial Workflow

```
Draft → In Review → Ready → Published
  ↓         ↓         ↓         ↓
Editor  Supervisor  Approve   Live
Creates  Reviews    Decision  Website
```

The workflow maps to Git:
- **Draft** → Feature branch (`cms/draft/...`)
- **In Review** → Pull Request
- **Ready** → Approved PR
- **Published** → Merged to master → Deployed

---

## ✨ Features

- ✅ **Editorial Workflow** - Draft, review, and publish process
- ✅ **Multi-language** - English, Welsh (Cymraeg), Gaelic (Gàidhlig)
- ✅ **Git-based** - All changes version controlled
- ✅ **Local Backend** - Develop offline without authentication
- ✅ **Media Library** - Upload and manage images
- ✅ **Rich Text Editor** - Markdown with visual editing
- ✅ **Role-based Access** - Three user permission levels
- ✅ **Docker Ready** - Complete containerized environment

---

## 🌐 Local Development Access Points

| Service | URL | Port |
|---------|-----|------|
| CMS Admin | http://localhost:1313/admin/ | 1313 |
| Hugo Dev Server | http://localhost:1313 | 1313 |
| Production Build | http://localhost:1080 | 1080 |
| Git Gateway | http://localhost:8081 | 8081 |
| Auth Proxy | http://localhost:8082 | 8082 |

---

## 📁 Project Structure

```
ukwa-site-original/
├── static/admin/
│   ├── config.yml          # CMS configuration
│   └── index.html          # CMS interface
│
├── cms-config/             # User roles & auth config
│   ├── nginx.conf
│   └── users/
│       ├── supervisor.json
│       ├── editor.json
│       └── viewer.json
│
├── docs/                   # Documentation
│   ├── USER_GUIDE.md       # For content editors
│   └── DEVOPS_GUIDE.md     # For tech teams
│
├── docker-compose-integrated.cms.yml  # Dev environment
├── start-cms-local.sh      # Startup script
├── stop-cms-local.sh       # Shutdown script
│
└── README_CMS.md           # This file
```

---

## 🔒 Security

### Local Development
- Works directly with local files
- No authentication required
- Offline capable

### Production
- OAuth authentication (GitHub/GitLab)
- JWT token-based authorization
- HTTPS required
- Branch protection rules
- Git audit trail

See [docs/DEVOPS_GUIDE.md](docs/DEVOPS_GUIDE.md) for complete security setup.

---

## 📊 Deployment Options

### Option 1: Netlify (Recommended for Quick Start)
- Built-in Git Gateway and authentication
- Automatic HTTPS and CDN
- Setup time: ~30 minutes
- **Guide:** [docs/DEVOPS_GUIDE.md](docs/DEVOPS_GUIDE.md#option-1-netlify-recommended-for-easy-setup)

### Option 2: GitHub + Custom Git Gateway
- Full control over infrastructure
- Self-hosted option available
- Setup time: 2-4 hours
- **Guide:** [docs/DEVOPS_GUIDE.md](docs/DEVOPS_GUIDE.md#option-2-github-with-custom-git-gateway)

### Option 3: Azure Static Web Apps
- Native Azure integration
- Built-in CI/CD
- Setup time: 1-2 hours
- **Guide:** [docs/DEVOPS_GUIDE.md](docs/DEVOPS_GUIDE.md#option-4-azure-static-web-apps)

---

## 🧪 Testing

Follow the comprehensive testing checklist:
```bash
# 1. Validate configuration
npx js-yaml static/admin/config.yml

# 2. Start environment
./start-cms-local.sh

# 3. Test CMS
open http://localhost:1313/admin/

# 4. Follow full checklist
# See TESTING_CHECKLIST.md for 15 test phases
```

---

## 💡 Common Commands

```bash
# Start CMS environment
./start-cms-local.sh

# Stop CMS environment
./stop-cms-local.sh

# Validate CMS config
npx js-yaml static/admin/config.yml

# Check running containers
docker ps | grep ukwa-site-original

# View logs
docker compose -f docker-compose-integrated.cms.yml logs -f

# Check git status
git status

# Test CMS endpoint
curl -I http://localhost:1313/admin/
```

---

## 🆘 Troubleshooting

### CMS won't load?
```bash
# Restart Hugo
docker compose -f docker-compose-integrated.cms.yml restart hugo-dev
# Or manually: hugo server -D
```

### Can't save content?
```bash
# Check decap-server is running
docker ps | grep git-gateway
# Start if needed: npx decap-server
```

### Docker issues?
```bash
# Check Docker is running
docker info

# View container logs
docker compose -f docker-compose-integrated.cms.yml logs

# Restart everything
./stop-cms-local.sh && ./start-cms-local.sh
```

For detailed troubleshooting:
- [docs/USER_GUIDE.md#troubleshooting](docs/USER_GUIDE.md#troubleshooting)
- [docs/DEVOPS_GUIDE.md#troubleshooting](docs/DEVOPS_GUIDE.md#troubleshooting)

---

## 📝 Next Steps

### Immediate (Testing Phase)
1. ✅ Integration complete
2. ☐ Start local environment
3. ☐ Test all CMS features
4. ☐ Review documentation
5. ☐ Verify multi-language support

### Short-term (1-2 weeks)
6. ☐ Choose deployment platform
7. ☐ Set up production environment
8. ☐ Configure authentication
9. ☐ Invite users
10. ☐ Conduct training

### Medium-term (1 month)
11. ☐ Configure CI/CD pipeline
12. ☐ Set up monitoring
13. ☐ Establish backup strategy
14. ☐ Optimize workflow
15. ☐ Gather user feedback

---

## 📈 What's Included

### Files Modified (2)
- `static/admin/config.yml` - Enabled editorial workflow
- `static/admin/index.html` - Updated to Decap CMS v3.3.3

### Files Created (15)
- Complete Docker Compose setup
- User role configurations (3 roles)
- Comprehensive documentation (31,000+ words)
- Startup/shutdown scripts
- Testing checklist (15 phases)
- Implementation guides

### Total
- **17 files** modified/created
- **~160 KB** of configuration and documentation
- **2 new directories** (cms-config, docs)

---

## 🎓 Training Resources

### For Content Editors
- Review [docs/USER_GUIDE.md](docs/USER_GUIDE.md)
- Practice in local environment
- Understand the workflow
- Learn multi-language editing

### For Technical Staff
- Read [docs/DEVOPS_GUIDE.md](docs/DEVOPS_GUIDE.md)
- Understand Git Gateway
- Learn deployment options
- Configure production environment

---

## 🔗 Resources

### Official Documentation
- **Decap CMS:** https://decapcms.org/docs/
- **Hugo:** https://gohugo.io/documentation/
- **Git Gateway:** https://github.com/netlify/git-gateway

### Community
- **Decap CMS Discussions:** https://github.com/decaporg/decap-cms/discussions
- **Hugo Forum:** https://discourse.gohugo.io/

### Repository
- **GitHub:** https://github.com/ukwa/ukwa-site
- **Issues:** https://github.com/ukwa/ukwa-site/issues

---

## 🤝 Support

1. **Check documentation first:**
   - This README
   - CMS_INTEGRATION_README.md
   - docs/USER_GUIDE.md or docs/DEVOPS_GUIDE.md

2. **Search existing issues:**
   - https://github.com/ukwa/ukwa-site/issues

3. **Create new issue:**
   - Provide detailed description
   - Include error messages
   - Attach screenshots if relevant

4. **Contact team:**
   - DevOps for technical issues
   - Content manager for workflow questions

---

## 📜 License

See repository license file.

---

## ✅ Status

**Implementation:** Complete ✅
**Testing:** Ready 🔄
**Production:** Pending ⏳

**Version:** 1.0
**Date:** 2025-01-28
**Integration Status:** Ready for deployment

---

## 🎯 Quick Links

- 📖 [Quick Start Guide](CMS_INTEGRATION_README.md)
- 👤 [User Guide (Non-Technical)](docs/USER_GUIDE.md)
- 🔧 [DevOps Guide (Technical)](docs/DEVOPS_GUIDE.md)
- ✅ [Testing Checklist](TESTING_CHECKLIST.md)
- 📊 [Implementation Summary](IMPLEMENTATION_SUMMARY.md)
- 📁 [Files Created](FILES_CREATED.md)

---

**Ready to get started?**

```bash
./start-cms-local.sh
open http://localhost:1313/admin/
```

Happy content managing! 🚀

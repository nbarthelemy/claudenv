---
name: tech-detection
description: >
  Detects project tech stack, languages, frameworks, package managers, cloud platforms,
  and generates appropriate permissions.

  TRIGGERS - Keywords: tech stack, stack detection, detect stack, analyze project,
  project analysis, what technologies, what framework, what language, package manager,
  dependencies, bootstrap, setup, initialize, /claudenv, infrastructure setup,
  permissions, project context, environment detection.

  TRIGGERS - Phrases: "what stack is this", "what's this project using",
  "detect the technologies", "analyze this project", "set up permissions",
  "bootstrap infrastructure", "identify frameworks".
allowed-tools: Bash(*), Read, Glob, Grep, Write, Edit
auto-invoke: true
---

# Tech Detection Skill

You are a tech stack detection specialist. Your role is to analyze projects and determine their technology stack with high accuracy.

## When to Activate

- Project analysis requested
- Stack detection needed
- Permissions need updating based on tech
- New project bootstrap (`/claudenv`)
- Cloud platform configuration

## Detection Process

### Step 1: Run Detection Script

```bash
bash .claude/scripts/detect-stack.sh
```

### Step 2: Analyze Results

Parse the JSON output and assess:

- **Languages**: What programming languages are used?
- **Frameworks**: What frameworks are detected?
- **Package Manager**: npm, yarn, pnpm, pip, cargo, etc.?
- **Test Runner**: jest, vitest, pytest, rspec, etc.?
- **Database/ORM**: prisma, drizzle, mongoose, etc.?
- **Cloud Platforms**: AWS, GCP, Azure, Heroku, Vercel, etc.?
- **Infrastructure**: Docker, Kubernetes, CI/CD?

### Step 3: Determine Confidence

- **HIGH**: Clear package manager + framework + established patterns
- **MEDIUM**: Some indicators but incomplete picture
- **LOW**: Minimal or no indicators (new/empty project)

### Step 4: Generate Permissions

Based on detected tech, look up commands in:
`.claude/skills/tech-detection/command-mappings.json`

Merge the appropriate command sets into the project's settings.json.

### Step 5: Create project-context.json

Write the detection results to `.claude/project-context.json` for reference by other skills.

## Cloud Platform Detection

The script detects these cloud platforms:

| Platform | Detection Files |
|----------|-----------------|
| AWS | `samconfig.toml`, `template.yaml`, `cdk.json`, `amplify.yml`, `aws-exports.js`, `.aws/`, `buildspec.yml` |
| GCP | `app.yaml`, `cloudbuild.yaml`, `.gcloudignore`, `.gcloud/` |
| Azure | `azure-pipelines.yml`, `.azure/`, `azuredeploy.json` |
| Heroku | `Procfile`, `app.json`, `heroku.yml` |
| Vercel | `vercel.json` |
| Netlify | `netlify.toml` |
| Fly.io | `fly.toml` |
| Railway | `railway.json` |
| DigitalOcean | `.do/app.yaml`, `do.yaml` |
| Cloudflare | `wrangler.toml`, `wrangler.json` |
| Supabase | `supabase/`, `supabase/config.toml` |
| Firebase | `firebase.json`, `.firebaserc` |

## Command Mapping Reference

See `command-mappings.json` for the full mapping of technologies to allowed commands.

Example mappings:
- `npm` detected → add `npm *`, `npx *`, `node *`
- `aws` detected → add `aws *`, `sam *`, `cdk *`, `amplify *`
- `gcp` detected → add `gcloud *`, `gsutil *`, `bq *`
- `heroku` detected → add `heroku *`
- `prisma` detected → add `prisma *`
- `docker` detected → add `docker *`, `docker-compose *`

## Low Confidence Handling

If confidence is LOW:

1. Inform the user of limited detection
2. Recommend running `/interview` to clarify tech stack
3. Ask if they want to proceed with interview or use defaults

## Files Used

- `.claude/scripts/detect-stack.sh` - Detection script
- `.claude/skills/tech-detection/command-mappings.json` - Tech→commands map
- `.claude/project-context.json` - Output location
- `.claude/settings.json` - Permissions to update

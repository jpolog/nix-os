{
  "details": [
    {
      "globs": [
        "**/*mcp*",
        "**/mcp/**"
      ],
      "name": "mcp-builder",
      "path": "~/.omp/agent/skills/mcp-builder/SKILL.md",
      "supportFiles": [
        "reference/",
        "scripts/"
      ]
    },
    {
      "globs": [
        "**/*"
      ],
      "name": "skill-creator",
      "path": "~/.omp/agent/skills/skill-creator/SKILL.md",
      "supportFiles": [
        "scripts/"
      ]
    },
    {
      "globs": [
        "**/*test*.{js,ts,py,rs,go}",
        "**/tests/**"
      ],
      "name": "webapp-testing",
      "path": "~/.omp/agent/skills/webapp-testing/SKILL.md",
      "supportFiles": [
        "scripts/",
        "examples/"
      ]
    },
    {
      "globs": [
        "**/*"
      ],
      "name": "content-research-writer",
      "path": "~/.omp/agent/skills/content-research-writer/SKILL.md",
      "supportFiles": []
    },
    {
      "globs": [
        "**/*.css",
        "**/*.scss",
        "**/*.tsx",
        "**/*.vue"
      ],
      "name": "theme-factory",
      "path": "~/.omp/agent/skills/theme-factory/SKILL.md",
      "supportFiles": [
        "themes/",
        "theme-showcase.pdf"
      ]
    },
    {
      "globs": [
        "**/CHANGELOG*",
        "**/package.json"
      ],
      "name": "changelog-generator",
      "path": "~/.omp/agent/skills/changelog-generator/SKILL.md",
      "supportFiles": []
    },
    {
      "globs": [
        "**/*"
      ],
      "name": "file-organizer",
      "path": "~/.omp/agent/skills/file-organizer/SKILL.md",
      "supportFiles": []
    },
    {
      "globs": [
        "**/*.{png,jpg,jpeg,svg,webp}"
      ],
      "name": "image-enhancer",
      "path": "~/.omp/agent/skills/image-enhancer/SKILL.md",
      "supportFiles": []
    },
    {
      "globs": [
        "**/*"
      ],
      "name": "developer-growth-analysis",
      "path": "~/.omp/agent/skills/developer-growth-analysis/SKILL.md",
      "supportFiles": []
    },
    {
      "globs": [
        "**/*"
      ],
      "name": "langsmith-fetch",
      "path": "~/.omp/agent/skills/langsmith-fetch/SKILL.md",
      "supportFiles": []
    },
    {
      "globs": [
        "**/*.docx"
      ],
      "name": "docx",
      "path": "~/.omp/agent/skills/docx/SKILL.md",
      "supportFiles": [
        "docx-js.md",
        "ooxml.md",
        "ooxml/",
        "scripts/"
      ]
    },
    {
      "globs": [
        "**/*.pdf"
      ],
      "name": "pdf",
      "path": "~/.omp/agent/skills/pdf/SKILL.md",
      "supportFiles": [
        "forms.md",
        "reference.md",
        "scripts/"
      ]
    },
    {
      "globs": [
        "**/*.pptx"
      ],
      "name": "pptx",
      "path": "~/.omp/agent/skills/pptx/SKILL.md",
      "supportFiles": [
        "html2pptx.md",
        "ooxml.md",
        "ooxml/",
        "scripts/"
      ]
    },
    {
      "globs": [
        "**/*.xlsx"
      ],
      "name": "xlsx",
      "path": "~/.omp/agent/skills/xlsx/SKILL.md",
      "supportFiles": [
        "recalc.py"
      ]
    }
  ],
  "notes": "All skills have OMP frontmatter (name, description, globs, alwaysApply: false). Original frontmatter was stripped and replaced. Support subdirectories (reference/, scripts/, examples/, themes/, ooxml/) were copied for skills that had them.",
  "skillsCopied": 14
}
---
title:Markdown Presentation (mdprs)
author:Thomas Bonk
description:This presentation documents the feature of mdprs.
theme: sky
style-text-align: left
---

# Markdown Presentation (mdprs)
## Features and Recipes
### Thomas Bonk

---

## Structure

A presentation is written as Markdown. A simple presentation looks like this:

```markdown
# Slide 1
---
# Slide 2
---
# Slide 3
```

Slides are separated with `---`.

---

## Metadata

Metadata for a presentation is placed between two `---` lines Xat the beginning of the file:

```markdown
---
title: A title
description: A cool slide deck
---
# Slide 1
```

The following attributes are available:

- `title`: Presentation title; is provided in the title tag of the HTML header.
- `author`: Author of the presentation; is provided as metadata in the HTML file.
- `description`: Description that is provided as metadata in the HTML file.
- `language`: ISO-639-1 language code.
- `theme`: The theme that shall be used.

---

## Themes

The following themes are predefined:

- beige
- black
- blood
- league
- moon
- night
- serif
- simple
- sky
- solarized
- white

Custom themes are not yet supported, but will be in a later version.

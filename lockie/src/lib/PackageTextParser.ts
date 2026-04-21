// Parser for human-readable text format -> Swipe[]
//
// Format: blocks separated by @type headers
// Packages separated by @package
// Segments defined with @segment (title on line 1, symbol on line 2)
//
// Comments: any line whose first non-whitespace character is "#" is a
// comment. Comment lines are stripped before parsing and never appear in
// the output. Comments can sit anywhere in the file (between blocks,
// inside blocks, between properties). Inline comments are NOT supported.
// Course colors are authored without a leading "#" (e.g. "color: 8461BD").
//
// @text
// Each line becomes a text segment.
// Supports <c:r>red</c:r> and <c:g>green</c:g> markup.
//
// @question
// What is the question?
//
// answer: First answer
// consequence: Consequence message
//
// answer: Second answer
// consequence: Consequence message
//
// correct_answers: 1
// explanation: Explanation text
// hint: Hint text
//
// @true_false
// Statement to evaluate
//
// true: True option text
// consequence: Consequence
//
// false: False option text
// consequence: Consequence
//
// correct_answers: 1
// explanation: Explanation text
// hint: Hint text
//
// @estimate
// What percentage?
// answer: 75
// explanation: Explanation
//
// @pause
// Motivational text
//
// @quote
// The quote text
// Author Name
//
// @reflect
// Thinking point one
// Thinking point two

import type { Swipe, Accelerator, Segment, Package } from "@/types/Course";
import { DEFAULT_COURSE_COLOR } from "@/types/Course";

// * Comment stripping

// Removes full-line comments before any other parsing happens.
// A line is a comment when its first non-whitespace character is "#".
// Comments never reach the block splitter, so they cannot affect block
// boundaries, property parsing, or text-segment output.
function stripComments(input: string): string {
  return input
    .split("\n")
    .filter((line) => !line.trimStart().startsWith("#"))
    .join("\n");
}

// * Block splitting

interface RawBlock {
  type: string;
  lines: string[];
}

function splitIntoBlocks(input: string): RawBlock[] {
  const blocks: RawBlock[] = [];
  let currentType = "";
  let currentLines: string[] = [];

  for (const rawLine of input.split("\n")) {
    const trimmed = rawLine.trim();
    const headerMatch = trimmed.match(/^@(\w+)$/);

    if (headerMatch) {
      const hasExistingBlock = currentType !== "";

      if (hasExistingBlock) {
        blocks.push({ type: currentType, lines: currentLines });
      }

      currentType = headerMatch[1].toLowerCase();
      currentLines = [];
    } else {
      currentLines.push(rawLine);
    }
  }

  const hasTrailingBlock = currentType !== "";

  if (hasTrailingBlock) {
    blocks.push({ type: currentType, lines: currentLines });
  }

  return blocks;
}

// * Block parsers

function parseTextBlock(lines: string[]): Swipe {
  const segments = lines
    .filter((line) => line.trim() !== "")
    .map((line) => line.trim());

  const hasNoSegments = segments.length === 0;

  if (hasNoSegments) {
    return { "entity-type": "text", "text-segments": [""] };
  }

  return { "entity-type": "text", "text-segments": segments };
}

interface ParsedOption {
  text: string;
  consequenceMessage: string;
}

function parseQuestionBlock(lines: string[]): Swipe {
  const contentLines = lines.filter((line) => line.trim() !== "");

  const questionParts: string[] = [];
  const options: ParsedOption[] = [];
  let correctIndices: number[] = [];
  let explanation = "";
  let hint = "";

  for (const line of contentLines) {
    const trimmed = line.trim();

    if (trimmed.startsWith("answer:")) {
      options.push({
        text: trimmed.slice("answer:".length).trim(),
        consequenceMessage: "",
      });
    } else if (trimmed.startsWith("consequence:")) {
      const hasOptions = options.length > 0;

      if (hasOptions) {
        options[options.length - 1].consequenceMessage = trimmed
          .slice("consequence:".length)
          .trim();
      }
    } else if (trimmed.startsWith("correct_answers:")) {
      correctIndices = trimmed
        .slice("correct_answers:".length)
        .trim()
        .split(",")
        .map((s) => parseInt(s.trim(), 10) - 1)
        .filter((n) => !isNaN(n));
    } else if (trimmed.startsWith("explanation:")) {
      explanation = trimmed.slice("explanation:".length).trim();
    } else if (trimmed.startsWith("hint:")) {
      hint = trimmed.slice("hint:".length).trim();
    } else {
      questionParts.push(trimmed);
    }
  }

  const question = questionParts.join(" ");

  return {
    "entity-type": "question",
    question,
    explanation,
    hint,
    options: options.map((opt) => ({
      text: opt.text,
      "consequence-message": opt.consequenceMessage,
    })),
    "correct-answer-indices": correctIndices.length > 0 ? correctIndices : [0],
  };
}

function parseTrueFalseBlock(lines: string[]): Swipe {
  const contentLines = lines.filter((line) => line.trim() !== "");

  const statementParts: string[] = [];
  const options: ParsedOption[] = [];
  let correctIndices: number[] = [];
  let explanation = "";
  let hint = "";

  for (const line of contentLines) {
    const trimmed = line.trim();

    if (trimmed.startsWith("true:")) {
      options.push({
        text: trimmed.slice("true:".length).trim(),
        consequenceMessage: "",
      });
    } else if (trimmed.startsWith("false:")) {
      options.push({
        text: trimmed.slice("false:".length).trim(),
        consequenceMessage: "",
      });
    } else if (trimmed.startsWith("consequence:")) {
      const hasOptions = options.length > 0;

      if (hasOptions) {
        options[options.length - 1].consequenceMessage = trimmed
          .slice("consequence:".length)
          .trim();
      }
    } else if (trimmed.startsWith("correct_answers:")) {
      correctIndices = trimmed
        .slice("correct_answers:".length)
        .trim()
        .split(",")
        .map((s) => parseInt(s.trim(), 10) - 1)
        .filter((n) => !isNaN(n));
    } else if (trimmed.startsWith("explanation:")) {
      explanation = trimmed.slice("explanation:".length).trim();
    } else if (trimmed.startsWith("hint:")) {
      hint = trimmed.slice("hint:".length).trim();
    } else {
      statementParts.push(trimmed);
    }
  }

  const question = statementParts.join(" ");

  return {
    "entity-type": "true-false-question",
    question,
    explanation,
    hint,
    options: options.map((opt) => ({
      text: opt.text,
      "consequence-message": opt.consequenceMessage,
    })),
    "correct-answer-indices": correctIndices.length > 0 ? correctIndices : [0],
  };
}

function parseEstimateBlock(lines: string[]): Swipe {
  const contentLines = lines.filter((line) => line.trim() !== "");

  const questionParts: string[] = [];
  let answer = 50;
  let explanation = "";
  let hint = "";

  for (const line of contentLines) {
    const trimmed = line.trim();

    if (trimmed.startsWith("answer:")) {
      const parsed = parseInt(trimmed.slice("answer:".length).trim(), 10);
      const isValidNumber = !isNaN(parsed);

      if (isValidNumber) {
        answer = parsed;
      }
    } else if (trimmed.startsWith("explanation:")) {
      explanation = trimmed.slice("explanation:".length).trim();
    } else if (trimmed.startsWith("hint:")) {
      hint = trimmed.slice("hint:".length).trim();
    } else {
      questionParts.push(trimmed);
    }
  }

  const question = questionParts.join(" ");

  return {
    "entity-type": "estimate",
    question,
    explanation,
    hint,
    "correct-answer-indices": [answer],
    "close-threshold": 10,
  };
}

function parsePauseBlock(lines: string[]): Swipe {
  const contentLines = lines.filter((line) => line.trim() !== "");
  const text = contentLines.map((l) => l.trim()).join(" ");

  return { "entity-type": "pause", text, icon: "check" };
}

function parseQuoteBlock(lines: string[]): Swipe {
  const contentLines = lines.filter((line) => line.trim() !== "");

  const quote = contentLines.length > 0 ? contentLines[0].trim() : "";
  const author = contentLines.length > 1 ? contentLines[1].trim() : "";

  return { "entity-type": "quote", quote, author };
}

function parseReflectionBlock(lines: string[]): Swipe {
  const thinkingPoints = lines
    .filter((line) => line.trim() !== "")
    .map((line) => line.trim());

  return {
    "entity-type": "reflect",
    prompt: "",
    "thinking-points": thinkingPoints.length > 0 ? thinkingPoints : [""],
  };
}

// * Package metadata extraction

interface PackageMetadata {
  title: string;
  isFree: boolean;
  contentText: string;
}

function extractPackageMetadata(sectionText: string, fallbackTitle: string): PackageMetadata {
  const firstBlockIndex = sectionText.search(/^@\w+\s*$/m);

  const hasNoContentBlocks = firstBlockIndex === -1;

  if (hasNoContentBlocks) {
    return { title: fallbackTitle, isFree: false, contentText: sectionText };
  }

  const headerText = sectionText.slice(0, firstBlockIndex);
  const contentText = sectionText.slice(firstBlockIndex);

  const headerLines = headerText
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line !== "");

  let title = fallbackTitle;
  let isFree = false;

  for (const line of headerLines) {
    const isFreeLine = line.toLowerCase() === "free";

    if (isFreeLine) {
      isFree = true;
    } else {
      title = line;
    }
  }

  return { title, isFree, contentText };
}

// * Main parser

export function parsePackageText(input: string): Swipe[] {
  const cleaned = stripComments(input);
  const blocks = splitIntoBlocks(cleaned);
  const swipes: Swipe[] = [];

  for (const block of blocks) {
    switch (block.type) {
      case "text": {
        swipes.push(parseTextBlock(block.lines));
        break;
      }

      case "question": {
        swipes.push(parseQuestionBlock(block.lines));
        break;
      }

      case "true_false": {
        swipes.push(parseTrueFalseBlock(block.lines));
        break;
      }

      case "estimate": {
        swipes.push(parseEstimateBlock(block.lines));
        break;
      }

      case "pause": {
        swipes.push(parsePauseBlock(block.lines));
        break;
      }

      case "quote": {
        swipes.push(parseQuoteBlock(block.lines));
        break;
      }

      case "reflect": {
        swipes.push(parseReflectionBlock(block.lines));
        break;
      }
    }
  }

  return swipes;
}

// * Course parser (whole course from .rlockie file)

interface ParsedCourseInfo {
  id: string;
  language: string;
  title: string;
  author: string;
  description: string;
  color: string;
  genres: string[];
  relevantFor: string[];
}

function parseCourseInfoSection(text: string): ParsedCourseInfo {
  const info: ParsedCourseInfo = {
    id: "",
    language: "EN",
    title: "",
    author: "",
    description: "",
    color: DEFAULT_COURSE_COLOR,
    genres: [],
    relevantFor: [],
  };

  for (const line of text.split("\n")) {
    const trimmed = line.trim();

    if (trimmed.startsWith("id:")) {
      info.id = trimmed.slice("id:".length).trim();
    } else if (trimmed.startsWith("language:")) {
      info.language = trimmed.slice("language:".length).trim() || "EN";
    } else if (trimmed.startsWith("title:")) {
      info.title = trimmed.slice("title:".length).trim();
    } else if (trimmed.startsWith("author:")) {
      info.author = trimmed.slice("author:".length).trim();
    } else if (trimmed.startsWith("description:")) {
      info.description = trimmed.slice("description:".length).trim();
    } else if (trimmed.startsWith("color:")) {
      // .rlockie files are authored without a leading "#" (it would be parsed as a comment marker).
      // Internally we keep the "#" so the value can flow directly into CSS backgroundColor bindings.
      const rawColor = trimmed.slice("color:".length).trim().replace(/^#/, "");
      info.color = rawColor === "" ? info.color : `#${rawColor}`;
    } else if (trimmed.startsWith("genres:")) {
      info.genres = trimmed
        .slice("genres:".length)
        .trim()
        .split(",")
        .map((g) => g.trim())
        .filter((g) => g !== "");
    } else if (trimmed.startsWith("relevant_for:")) {
      info.relevantFor = trimmed
        .slice("relevant_for:".length)
        .trim()
        .split(",")
        .map((r) => r.trim())
        .filter((r) => r !== "");
    }
  }

  return info;
}

// * Segment parser

function parseSegmentBlock(text: string, segmentNumber: number, courseId: string): Segment {
  const lines = text.split("\n").filter((line) => line.trim() !== "");

  const title = lines.length > 0 ? lines[0].trim() : `Segment ${segmentNumber}`;
  const symbol =
    lines.length > 1 ? lines[1].trim() : title.charAt(0).toUpperCase();

  return {
    "segment-id": `${courseId};segment:${segmentNumber}`,
    "segment-title": title,
    "segment-symbol": symbol,
    lessons: [],
  };
}

export function parseCourseText(input: string): Accelerator {
  const cleaned = stripComments(input);

  // Strip @course header if present
  const strippedInput = cleaned.replace(/^@course\s*\n/, "");

  const sections = strippedInput.split(/\n@package\n/);

  const hasNoSections = sections.length === 0;

  if (hasNoSections) {
    return {
      "course-id": `course-${Date.now()}`,
      language: "EN",
      title: "Untitled Course",
      author: "",
      description: "",
      "cover-image-path": "",
      color: DEFAULT_COURSE_COLOR,
      "relevant-for": [],
      genres: [],
      segments: [],
    };
  }

  // Section[0] may contain both course info and a @segment block
  const firstSection = sections[0];
  const segmentHeaderIndex = firstSection.indexOf("\n@segment");

  const hasSegmentInFirstSection = segmentHeaderIndex !== -1;

  const courseInfoText = hasSegmentInFirstSection
    ? firstSection.slice(0, segmentHeaderIndex)
    : firstSection;

  const courseInfo = parseCourseInfoSection(courseInfoText);
  const courseId = courseInfo.id || `course-${Date.now()}`;

  const segments: Segment[] = [];
  let currentSegment: Segment | null = null;

  // Helper to build a lesson-id from current position
  function buildLessonId(segmentNumber: number, lessonNumber: number): string {
    return `${courseId};segment:${segmentNumber};lesson:${lessonNumber}`;
  }

  // Helper to create a fallback segment with proper id
  function createFallbackSegment(): Segment {
    const segmentNumber = segments.length + 1;

    return {
      "segment-id": `${courseId};segment:${segmentNumber}`,
      "segment-title": `Segment ${segmentNumber}`,
      "segment-symbol": String.fromCharCode(64 + segmentNumber),
      lessons: [],
    };
  }

  // Extract segment from first section if present
  if (hasSegmentInFirstSection) {
    const segmentText = firstSection.slice(
      segmentHeaderIndex + "\n@segment\n".length,
    );

    currentSegment = parseSegmentBlock(segmentText, segments.length + 1, courseId);
    segments.push(currentSegment);
  }

  // Process remaining sections (packages or segment definitions)
  for (let sectionIndex = 1; sectionIndex < sections.length; sectionIndex++) {
    const sectionText = sections[sectionIndex].trim();

    const hasNoContent = sectionText === "";

    if (hasNoContent) {
      continue;
    }

    // Check if a @segment appears anywhere in this section
    const segmentMarkerIndex = sectionText.indexOf("@segment");
    const hasSegmentMarker = segmentMarkerIndex !== -1;

    if (hasSegmentMarker) {
      // Content before @segment is a package for the current segment
      const packageContent = sectionText.slice(0, segmentMarkerIndex).trim();
      const hasPackageContent = packageContent !== "";

      if (hasPackageContent) {
        if (!currentSegment) {
          currentSegment = createFallbackSegment();
          segments.push(currentSegment);
        }

        const packageNumber = currentSegment.lessons.length + 1;
        const segmentNumber = segments.indexOf(currentSegment) + 1;
        const meta = extractPackageMetadata(packageContent, `Package ${packageNumber}`);
        const swipes = parsePackageText(meta.contentText);

        const pkg: Package = {
          "lesson-id": buildLessonId(segmentNumber, packageNumber),
          title: meta.title,
          isFree: meta.isFree,
          content: swipes,
        };

        currentSegment.lessons.push(pkg);
      }

      // Start the new segment
      const segmentText = sectionText.slice(
        segmentMarkerIndex + "@segment\n".length,
      );

      currentSegment = parseSegmentBlock(segmentText, segments.length + 1, courseId);
      segments.push(currentSegment);
      continue;
    }

    // No segment marker — this is a regular package section
    if (!currentSegment) {
      currentSegment = createFallbackSegment();
      segments.push(currentSegment);
    }

    const packageNumber = currentSegment.lessons.length + 1;
    const segmentNumber = segments.indexOf(currentSegment) + 1;
    const meta = extractPackageMetadata(sectionText, `Package ${packageNumber}`);
    const swipes = parsePackageText(meta.contentText);

    const pkg: Package = {
      "lesson-id": buildLessonId(segmentNumber, packageNumber),
      title: meta.title,
      isFree: meta.isFree,
      content: swipes,
    };

    currentSegment.lessons.push(pkg);
  }

  // Fallback: ensure at least one segment exists
  const hasNoSegments = segments.length === 0;

  if (hasNoSegments) {
    segments.push({
      "segment-id": `${courseId};segment:1`,
      "segment-title": "Segment 1",
      "segment-symbol": "A",
      lessons: [],
    });
  }

  return {
    "course-id": courseId,
    language: courseInfo.language || "EN",
    title: courseInfo.title || "Untitled Course",
    author: courseInfo.author,
    description: courseInfo.description,
    "cover-image-path": "",
    color: courseInfo.color,
    "relevant-for": courseInfo.relevantFor,
    genres: courseInfo.genres,
    segments,
  };
}

// * Format guide (for display in UI)

export const PACKAGE_TEXT_FORMAT_GUIDE = {
  extension: ".rlockie",
  blocks: [
    {
      name: "Comment",
      tag: "#",
      description:
        "Any line whose first non-whitespace character is # is a comment. Comment lines are stripped before parsing and never appear in the output. Use them to leave notes for yourself or other writers, mark draft sections, or temporarily disable a swipe by prefixing every line with #. Inline comments are not supported because # is also used inside hex color values.",
      example: `# This package still needs a stronger Phase 2 anchor.
# TODO: rewrite the museum scene.

@text
A man walks into a museum.`,
    },
    {
      name: "Course",
      tag: "@course",
      description:
        "Marks the beginning of a course definition. Course metadata (title, author, etc.) follows on subsequent lines.",
      example: `@course

id: book:my-course-title-abcd
language: EN
title: My Course
author: Author Name
description: A short description
color: 8461BD
genres: design, psychology
relevant_for: Designers, Developers`,
    },
    {
      name: "Package",
      tag: "@package",
      description:
        "Separates packages (lessons) within a segment. First line after @package is the display title. Add 'Free' on its own line to mark as free.",
      example: `@package
Introduction to Color
Free`,
    },
    {
      name: "Course Segment",
      tag: "@segment",
      description:
        "Defines a segment grouping. First line is the title, second line is the symbol. All packages after this until the next @segment belong to this segment.",
      example: `@segment
Basic Design
BD`,
    },
    {
      name: "Text",
      tag: "@text",
      description: "Each line becomes a separate text segment.",
      example: `@text
First line of text.
Second line of text.
Use <c:r>red</c:r> or <c:g>green</c:g> for color.`,
    },
    {
      name: "Question",
      tag: "@question",
      description:
        "Single-choice question. Use correct_answers to specify which answers are correct (1-based indices).",
      syntax: `answer:           answer text
consequence:      consequence (shown after picking)

answer:           another answer
consequence:      consequence

correct_answers:  1
explanation:      explanation
hint:             hint`,
      example: `@question
What is the capital of France?

answer: Paris
consequence: Correct!

answer: London
consequence: That's England's capital.

answer: Berlin
consequence: That's Germany's capital.

correct_answers: 1
explanation: Paris has been the capital since the 10th century.
hint: Think of the Eiffel Tower`,
    },
    {
      name: "True / False",
      tag: "@true_false",
      description:
        "True or false question. Use correct_answers to specify which is correct (1 for true, 2 for false).",
      syntax: `true:             true option text
consequence:      consequence

false:            false option text
consequence:      consequence

correct_answers:  1
explanation:      explanation
hint:             hint`,
      example: `@true_false
The Earth orbits the Sun.

true: It completes one orbit every year
consequence: Correct!

false: The Earth is stationary
consequence: Actually, it does orbit the Sun.

correct_answers: 1
explanation: Copernicus proved this.
hint: Think about what Copernicus discovered`,
    },
    {
      name: "Estimate",
      tag: "@estimate",
      description: "Percentage estimation question. The learner drags a slider to guess.",
      syntax: `answer:       correct answer (0-100)
explanation:  explanation
hint:         hint`,
      example: `@estimate
What % of Earth is covered by water?

answer: 71
explanation: About 71% of Earth's surface is water.
hint: It is higher than most people expect.`,
    },
    {
      name: "Quote",
      tag: "@quote",
      description: "First line is the quote, second line is the author.",
      example: `@quote
The only way to do great work is to love what you do.
Steve Jobs`,
    },
    {
      name: "Pause",
      tag: "@pause",
      description: "A breather slide that connects what was learned to something real.",
      example: `@pause
90% of first impressions come down to color. Once you know that, you start seeing the choices behind every interface.`,
    },
    {
      name: "Reflect",
      tag: "@reflect",
      description: "A reflection prompt. Each line is a thinking point that should make the reader see something familiar differently.",
      example: `@reflect
If every app uses the same cognitive shortcuts, are we designing for humans, or training humans to fit our designs?
Next time you feel frustrated by an interface, ask yourself: is the task actually hard, or is the design making it harder?`,
    },
  ],
};

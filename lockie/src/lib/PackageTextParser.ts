// Parser for human-readable text format -> Swipe[]
//
// Format: blocks separated by type:: headers
// Packages separated by --------
// Segments defined with course_segment:: (title on line 1, symbol on line 2)
//
// text::
// Each line becomes a text segment.
// Supports <c:r>red</c:r> and <c:g>green</c:g> markup.
//
// question::
// What is the question?
//
// answer=correct: Correct answer
// consequence: Consequence message
//
// answer: Wrong answer
// consequence: Consequence message
//
// explanation: Explanation text
// hint: Hint text
//
// true_false::
// Statement to evaluate
//
// true=correct: True option text
// consequence: Consequence
//
// false: False option text
// consequence: Consequence
//
// explanation: Explanation text
// hint: Hint text
//
// estimate::
// What percentage?
// answer: 75
// explanation: Explanation
//
// pause::
// Motivational text
//
// quote::
// The quote text
// Author Name
//
// reflect::
// Thinking point one
// Thinking point two

import type { Swipe, Accelerator, Segment, Package } from '@/types/Course'

// * Block splitting

interface RawBlock {
  type: string
  lines: string[]
}

function splitIntoBlocks(input: string): RawBlock[] {
  const blocks: RawBlock[] = []
  let currentType = ''
  let currentLines: string[] = []

  for (const rawLine of input.split('\n')) {
    const trimmed = rawLine.trim()
    const headerMatch = trimmed.match(/^(\w+)::$/)

    if (headerMatch) {
      const hasExistingBlock = currentType !== ''

      if (hasExistingBlock) {
        blocks.push({ type: currentType, lines: currentLines })
      }

      currentType = headerMatch[1].toLowerCase()
      currentLines = []
    } else {
      currentLines.push(rawLine)
    }
  }

  const hasTrailingBlock = currentType !== ''

  if (hasTrailingBlock) {
    blocks.push({ type: currentType, lines: currentLines })
  }

  return blocks
}

// * Block parsers

function parseTextBlock(lines: string[]): Swipe {
  const segments = lines
    .filter(line => line.trim() !== '')
    .map(line => line.trim())

  const hasNoSegments = segments.length === 0

  if (hasNoSegments) {
    return { 'entity-type': 'text', 'text-segments': [''] }
  }

  return { 'entity-type': 'text', 'text-segments': segments }
}

interface ParsedOption {
  text: string
  consequenceMessage: string
  isCorrect: boolean
}

function parseQuestionBlock(lines: string[]): Swipe {
  const contentLines = lines.filter(line => line.trim() !== '')

  const questionParts: string[] = []
  const options: ParsedOption[] = []
  let explanation = ''
  let hint = ''

  for (const line of contentLines) {
    const trimmed = line.trim()

    if (trimmed.startsWith('answer=correct:')) {
      options.push({ text: trimmed.slice('answer=correct:'.length).trim(), consequenceMessage: '', isCorrect: true })
    } else if (trimmed.startsWith('answer:')) {
      options.push({ text: trimmed.slice('answer:'.length).trim(), consequenceMessage: '', isCorrect: false })
    } else if (trimmed.startsWith('consequence:')) {
      const hasOptions = options.length > 0

      if (hasOptions) {
        options[options.length - 1].consequenceMessage = trimmed.slice('consequence:'.length).trim()
      }
    } else if (trimmed.startsWith('explanation:')) {
      explanation = trimmed.slice('explanation:'.length).trim()
    } else if (trimmed.startsWith('hint:')) {
      hint = trimmed.slice('hint:'.length).trim()
    } else {
      questionParts.push(trimmed)
    }
  }

  const question = questionParts.join(' ')

  const correctIndices = options
    .map((opt, idx) => opt.isCorrect ? idx : -1)
    .filter(idx => idx !== -1)

  return {
    'entity-type': 'single-choice-question',
    question,
    explanation,
    hint,
    options: options.map(opt => ({ text: opt.text, 'consequence-message': opt.consequenceMessage })),
    'correct-answer-indices': correctIndices.length > 0 ? correctIndices : [0],
  }
}

function parseTrueFalseBlock(lines: string[]): Swipe {
  const contentLines = lines.filter(line => line.trim() !== '')

  const statementParts: string[] = []
  const options: ParsedOption[] = []
  let explanation = ''
  let hint = ''

  for (const line of contentLines) {
    const trimmed = line.trim()

    if (trimmed.startsWith('true=correct:')) {
      options.push({ text: trimmed.slice('true=correct:'.length).trim(), consequenceMessage: '', isCorrect: true })
    } else if (trimmed.startsWith('true:')) {
      options.push({ text: trimmed.slice('true:'.length).trim(), consequenceMessage: '', isCorrect: false })
    } else if (trimmed.startsWith('false=correct:')) {
      options.push({ text: trimmed.slice('false=correct:'.length).trim(), consequenceMessage: '', isCorrect: true })
    } else if (trimmed.startsWith('false:')) {
      options.push({ text: trimmed.slice('false:'.length).trim(), consequenceMessage: '', isCorrect: false })
    } else if (trimmed.startsWith('consequence:')) {
      const hasOptions = options.length > 0

      if (hasOptions) {
        options[options.length - 1].consequenceMessage = trimmed.slice('consequence:'.length).trim()
      }
    } else if (trimmed.startsWith('explanation:')) {
      explanation = trimmed.slice('explanation:'.length).trim()
    } else if (trimmed.startsWith('hint:')) {
      hint = trimmed.slice('hint:'.length).trim()
    } else {
      statementParts.push(trimmed)
    }
  }

  const question = statementParts.join(' ')

  const correctIndices = options
    .map((opt, idx) => opt.isCorrect ? idx : -1)
    .filter(idx => idx !== -1)

  return {
    'entity-type': 'true-false-question',
    question,
    explanation,
    hint,
    options: options.map(opt => ({ text: opt.text, 'consequence-message': opt.consequenceMessage })),
    'correct-answer-indices': correctIndices.length > 0 ? correctIndices : [0],
  }
}

function parseEstimateBlock(lines: string[]): Swipe {
  const contentLines = lines.filter(line => line.trim() !== '')

  const questionParts: string[] = []
  let answer = 50
  let explanation = ''

  for (const line of contentLines) {
    const trimmed = line.trim()

    if (trimmed.startsWith('answer:')) {
      const parsed = parseInt(trimmed.slice('answer:'.length).trim(), 10)
      const isValidNumber = !isNaN(parsed)

      if (isValidNumber) {
        answer = parsed
      }
    } else if (trimmed.startsWith('explanation:')) {
      explanation = trimmed.slice('explanation:'.length).trim()
    } else {
      questionParts.push(trimmed)
    }
  }

  const question = questionParts.join(' ')

  return {
    'entity-type': 'estimate-percentage-question',
    question,
    explanation,
    options: [],
    'correct-answer-indices': [answer],
  }
}

function parsePauseBlock(lines: string[]): Swipe {
  const contentLines = lines.filter(line => line.trim() !== '')
  const text = contentLines.map(l => l.trim()).join(' ')

  return { 'entity-type': 'emotional-slide', text, icon: 'check' }
}

function parseQuoteBlock(lines: string[]): Swipe {
  const contentLines = lines.filter(line => line.trim() !== '')

  const quote = contentLines.length > 0 ? contentLines[0].trim() : ''
  const author = contentLines.length > 1 ? contentLines[1].trim() : ''

  return { 'entity-type': 'quote', quote, author }
}

function parseReflectionBlock(lines: string[]): Swipe {
  const thinkingPoints = lines
    .filter(line => line.trim() !== '')
    .map(line => line.trim())

  return {
    'entity-type': 'reflection',
    prompt: '',
    'thinking-points': thinkingPoints.length > 0 ? thinkingPoints : [''],
  }
}

// * Main parser

export function parsePackageText(input: string): Swipe[] {
  const blocks = splitIntoBlocks(input)
  const swipes: Swipe[] = []

  for (const block of blocks) {
    switch (block.type) {
      case 'text': {
        swipes.push(parseTextBlock(block.lines))
        break
      }

      case 'question': {
        swipes.push(parseQuestionBlock(block.lines))
        break
      }

      case 'true_false': {
        swipes.push(parseTrueFalseBlock(block.lines))
        break
      }

      case 'estimate': {
        swipes.push(parseEstimateBlock(block.lines))
        break
      }

      case 'pause': {
        swipes.push(parsePauseBlock(block.lines))
        break
      }

      case 'quote': {
        swipes.push(parseQuoteBlock(block.lines))
        break
      }

      case 'reflect': {
        swipes.push(parseReflectionBlock(block.lines))
        break
      }
    }
  }

  return swipes
}

// * Course parser (whole course from .rlockie file)

interface ParsedCourseInfo {
  title: string
  author: string
  description: string
  color: string
  genres: string[]
  relevantFor: string[]
}

function parseCourseInfoSection(text: string): ParsedCourseInfo {
  const info: ParsedCourseInfo = {
    title: '',
    author: '',
    description: '',
    color: '#6366f1',
    genres: [],
    relevantFor: [],
  }

  for (const line of text.split('\n')) {
    const trimmed = line.trim()

    if (trimmed.startsWith('title:')) {
      info.title = trimmed.slice('title:'.length).trim()
    } else if (trimmed.startsWith('author:')) {
      info.author = trimmed.slice('author:'.length).trim()
    } else if (trimmed.startsWith('description:')) {
      info.description = trimmed.slice('description:'.length).trim()
    } else if (trimmed.startsWith('color:')) {
      info.color = trimmed.slice('color:'.length).trim()
    } else if (trimmed.startsWith('genres:')) {
      info.genres = trimmed.slice('genres:'.length).trim().split(',').map(g => g.trim()).filter(g => g !== '')
    } else if (trimmed.startsWith('relevant_for:')) {
      info.relevantFor = trimmed.slice('relevant_for:'.length).trim().split(',').map(r => r.trim()).filter(r => r !== '')
    }
  }

  return info
}

// * Segment parser

function parseSegmentBlock(text: string, segmentNumber: number): Segment {
  const lines = text.split('\n').filter(line => line.trim() !== '')

  const title = lines.length > 0 ? lines[0].trim() : `Segment ${segmentNumber}`
  const symbol = lines.length > 1 ? lines[1].trim() : title.charAt(0).toUpperCase()

  return {
    'segment-id': `segment-${segmentNumber}`,
    'segment-title': title,
    'segment-description': '',
    'segment-symbol': symbol,
    lessons: [],
  }
}

export function parseCourseText(input: string): Accelerator {
  const sections = input.split(/\n--------\n/)

  const hasNoSections = sections.length === 0

  if (hasNoSections) {
    return {
      'course-id': `course-${Date.now()}`,
      title: 'Untitled Course',
      author: '',
      description: '',
      'cover-image-path': '',
      color: '#6366f1',
      'relevant-for': [],
      genres: [],
      segments: [],
    }
  }

  // Section[0] may contain both course info and a course_segment:: block
  const firstSection = sections[0]
  const segmentHeaderIndex = firstSection.indexOf('\ncourse_segment::')

  const hasSegmentInFirstSection = segmentHeaderIndex !== -1

  const courseInfoText = hasSegmentInFirstSection
    ? firstSection.slice(0, segmentHeaderIndex)
    : firstSection

  const courseInfo = parseCourseInfoSection(courseInfoText)

  const segments: Segment[] = []
  let currentSegment: Segment | null = null

  // Extract segment from first section if present
  if (hasSegmentInFirstSection) {
    const segmentText = firstSection.slice(segmentHeaderIndex + '\ncourse_segment::\n'.length)

    currentSegment = parseSegmentBlock(segmentText, segments.length + 1)
    segments.push(currentSegment)
  }

  // Process remaining sections (packages or segment definitions)
  for (let sectionIndex = 1; sectionIndex < sections.length; sectionIndex++) {
    const sectionText = sections[sectionIndex].trim()

    const hasNoContent = sectionText === ''

    if (hasNoContent) {
      continue
    }

    // Check if a course_segment:: appears anywhere in this section
    const segmentMarkerIndex = sectionText.indexOf('course_segment::')
    const hasSegmentMarker = segmentMarkerIndex !== -1

    if (hasSegmentMarker) {
      // Content before course_segment:: is a package for the current segment
      const packageContent = sectionText.slice(0, segmentMarkerIndex).trim()
      const hasPackageContent = packageContent !== ''

      if (hasPackageContent) {
        if (!currentSegment) {
          currentSegment = {
            'segment-id': 'segment-1',
            'segment-title': 'Segment 1',
            'segment-description': '',
            'segment-symbol': 'A',
            lessons: [],
          }

          segments.push(currentSegment)
        }

        const swipes = parsePackageText(packageContent)
        const packageNumber = currentSegment.lessons.length + 1

        const pkg: Package = {
          'lesson-id': `package-${packageNumber}`,
          title: `Package ${packageNumber}`,
          isFree: false,
          content: swipes,
        }

        currentSegment.lessons.push(pkg)
      }

      // Start the new segment
      const segmentText = sectionText.slice(segmentMarkerIndex + 'course_segment::\n'.length)

      currentSegment = parseSegmentBlock(segmentText, segments.length + 1)
      segments.push(currentSegment)
      continue
    }

    // No segment marker — this is a regular package section
    if (!currentSegment) {
      currentSegment = {
        'segment-id': 'segment-1',
        'segment-title': 'Segment 1',
        'segment-description': '',
        'segment-symbol': 'A',
        lessons: [],
      }

      segments.push(currentSegment)
    }

    const swipes = parsePackageText(sectionText)
    const packageNumber = currentSegment.lessons.length + 1
    const packageTitle = `Package ${packageNumber}`

    const pkg: Package = {
      'lesson-id': `package-${packageNumber}`,
      title: packageTitle,
      isFree: false,
      content: swipes,
    }

    currentSegment.lessons.push(pkg)
  }

  // Fallback: ensure at least one segment exists
  const hasNoSegments = segments.length === 0

  if (hasNoSegments) {
    segments.push({
      'segment-id': 'segment-1',
      'segment-title': 'Segment 1',
      'segment-description': '',
      'segment-symbol': 'A',
      lessons: [],
    })
  }

  return {
    'course-id': `course-${Date.now()}`,
    title: courseInfo.title || 'Untitled Course',
    author: courseInfo.author,
    description: courseInfo.description,
    'cover-image-path': '',
    color: courseInfo.color,
    'relevant-for': courseInfo.relevantFor,
    genres: courseInfo.genres,
    segments,
  }
}

// * Format guide (for display in UI)

export const PACKAGE_TEXT_FORMAT_GUIDE = {
  extension: '.rlockie',
  blocks: [
    {
      name: 'Course Segment',
      tag: 'course_segment::',
      description: 'Defines a segment grouping. First line is the title, second line is the symbol. All packages after this until the next course_segment:: belong to this segment.',
      example: `course_segment::
Basic Design
BD`,
    },
    {
      name: 'Text',
      tag: 'text::',
      description: 'Each line becomes a separate text segment.',
      example: `text::
First line of text.
Second line of text.
Use <c:r>red</c:r> or <c:g>green</c:g> for color.`,
    },
    {
      name: 'Question',
      tag: 'question::',
      description: 'Single-choice question. Mark the correct answer with answer=correct instead of answer.',
      syntax: `answer=correct:  correct answer
consequence:     consequence (shown after picking)

answer:          wrong answer
consequence:     consequence

explanation:     explanation
hint:            hint`,
      example: `question::
What is the capital of France?

answer=correct: Paris
consequence: Correct!

answer: London
consequence: That's England's capital.

answer: Berlin
consequence: That's Germany's capital.

explanation: Paris has been the capital since the 10th century.
hint: Think of the Eiffel Tower`,
    },
    {
      name: 'True / False',
      tag: 'true_false::',
      description: 'True or false question. Mark the correct side with true=correct or false=correct.',
      syntax: `true=correct:   true option text (correct)
consequence:    consequence

false:          false option text
consequence:    consequence

explanation:    explanation
hint:           hint`,
      example: `true_false::
The Earth orbits the Sun.

true=correct: It completes one orbit every year
consequence: Correct!

false: The Earth is stationary
consequence: Actually, it does orbit the Sun.

explanation: Copernicus proved this.
hint: Think about what Copernicus discovered`,
    },
    {
      name: 'Estimate',
      tag: 'estimate::',
      description: 'Percentage estimation question.',
      syntax: `answer:       correct answer (number)
explanation:  explanation`,
      example: `estimate::
What % of Earth is covered by water?
answer: 71
explanation: About 71% of Earth's surface is water.`,
    },
    {
      name: 'Quote',
      tag: 'quote::',
      description: 'First line is the quote, second line is the author.',
      example: `quote::
The only way to do great work is to love what you do.
Steve Jobs`,
    },
    {
      name: 'Pause',
      tag: 'pause::',
      description: 'Motivational break slide.',
      example: `pause::
Great job, keep going!`,
    },
    {
      name: 'Reflect',
      tag: 'reflect::',
      description: 'Each line becomes a thinking point.',
      example: `reflect::
Think about your morning routine
Consider your work habits
How could you apply this today?`,
    },
  ],
}

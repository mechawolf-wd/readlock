# Course Creation Guidelines for AI

## Overview
This document provides guidelines for creating engaging, story-driven courses that combine narrative elements with interactive learning. Follow this structure to create courses similar to "Design of Everyday Things."

## Course Structure Template

### 1. Course Introduction (IntroContent)
- **Purpose**: Set the stage and create curiosity
- **Format**: 3-4 text segments using `List<String>`
- **Content Guidelines**:
  - Start with a compelling question or scenario
  - Explain what learners will discover
  - Promise transformation or new perspective
  - Keep segments conversational and intriguing

**Example Pattern**:
```
[
  "Welcome to a journey that will change how you see [topic].",
  "Every [relevant object/concept] around you is [doing something interesting].",
  "Let's learn to [key skill or insight]."
]
```

### 2. Story Sections (TextContent)
- **Purpose**: Make abstract concepts concrete through relatable narratives
- **Format**: 4-6 text segments per story
- **Content Guidelines**:
  - Use real characters with names (Sarah, Marcus, Elena)
  - Create specific, vivid scenarios
  - Show the problem/situation before explaining the principle
  - Make it relatable to everyday experience

**Story Structure**:
1. Character introduction + situation
2. The problem/confusion occurs
3. Character's reaction/attempt to solve
4. The revelation or insight
5. Connection to broader principle
6. Universal application

**Example**:
```
TextContent(
  id: 'character_story',
  title: 'Sarah\'s Morning Mystery',
  textSegments: [
    'Sarah rushed through the hotel lobby, late for her presentation.',
    'She approached the exit - a sleek glass door with no visible handle.',
    'Her brain made an instant calculation: "This must be pulled."',
    'She grabbed the metal plate and tugged. Nothing.',
    'Embarrassed, she pushed instead. The door swung open effortlessly.',
    'As Sarah walked away, something clicked about design communication.',
  ],
),
```

### 3. Interactive Questions (QuestionContent)
- **Purpose**: Test understanding and reinforce key concepts
- **Placement**: After every 2-3 story sections
- **Content Guidelines**:
  - Ask about the principle demonstrated in the story
  - Include scenario-based options when possible
  - Provide meaningful explanations
  - Use humor appropriately in explanations

**Question Types**:
- **Principle Application**: "What design principle did Sarah encounter?"
- **Scenario Analysis**: "Which example shows good affordances?"
- **Real-world Connection**: "How would you improve this design?"

**Example**:
```
QuestionContent(
  id: 'design_question',
  title: 'Understanding Affordances',
  question: 'Why did Sarah initially try to pull the door?',
  options: [
    QuestionOption(text: 'The door looked heavy and solid'),
    QuestionOption(text: 'The metal plate looked like a handle to pull'),
    QuestionOption(text: 'She was in a hurry and not thinking clearly'),
    QuestionOption(text: 'Hotel doors are usually pull doors'),
  ],
  correctAnswerIndices: [1],
  explanation: 'The metal plate created a false affordance - it looked like something meant to be pulled, even though it was actually a push plate.',
),
```

### 4. Deep Dive Explanations (TextContent)
- **Purpose**: Provide thorough understanding of concepts
- **When to Use**: After introducing a principle through story
- **Content Guidelines**:
  - Explain the "why" behind the principle
  - Use clear, jargon-free language
  - Include multiple examples
  - Connect to psychology or science when relevant

### 5. Course Conclusion (OutroContent)
- **Purpose**: Summarize learning and inspire application
- **Format**: 3-4 text segments
- **Content Guidelines**:
  - Recap the journey and key insights
  - Emphasize transformation in perspective
  - Encourage real-world application
  - End with an empowering statement

## Content Writing Principles

### Tone and Voice
- **Conversational**: Write like talking to a friend
- **Curious**: Ask questions, create wonder
- **Empathetic**: Acknowledge frustrations and confusion
- **Optimistic**: Focus on solutions and understanding
- **Accessible**: Avoid jargon, explain complex concepts simply

### Storytelling Techniques
1. **Show, Don't Tell**: Use scenarios instead of abstract explanations
2. **Relatable Characters**: Create diverse, realistic personas
3. **Specific Details**: "Metal plate" not "door hardware"
4. **Emotional Connection**: Include frustration, relief, "aha" moments
5. **Universal Experiences**: Choose situations most people encounter

### Text Segmentation Rules
- **One idea per segment**: Each string should contain one complete thought
- **Natural breaks**: Segment where you'd naturally pause when speaking
- **Optimal length**: 15-30 words per segment for good pacing
- **Rhythm variation**: Mix short punchy segments with longer descriptive ones

### Example Segmentation:
```
❌ Poor segmentation:
[
  "Sarah rushed through the hotel lobby, late for her presentation. She approached the exit - a sleek glass door with no visible handle. Just a smooth metal plate mounted vertically on the right side."
]

✅ Good segmentation:
[
  "Sarah rushed through the hotel lobby, late for her presentation.",
  "She approached the exit - a sleek glass door with no visible handle.",
  "Just a smooth metal plate mounted vertically on the right side.",
  "Her brain made an instant calculation: 'This must be pulled.'"
]
```

## Technical Requirements

### Content Structure
- Use appropriate content types: `IntroContent`, `TextContent`, `QuestionContent`, `OutroContent`
- All text fields use `List<String>` format (textSegments, introTextSegments, outroTextSegments)
- Questions include proper options, correct answers, and explanations
- Each piece of content has unique ID and descriptive title

### Course Flow
1. **Introduction** (1 IntroContent)
2. **Learning Sections** (3-5 sections, each with):
   - 2-3 TextContent stories
   - 1-2 QuestionContent assessments
   - 1 explanatory TextContent (optional)
3. **Conclusion** (1 OutroContent)
4. **Examples Showcase** (automatically added)

## Subject-Specific Adaptations

### For Technical Topics
- Use more detailed scenarios
- Include troubleshooting stories
- Focus on practical applications
- Add "what if" scenarios in questions

### For Creative Topics
- Emphasize inspiration and creativity
- Include artistic or emotional elements
- Use more metaphors and analogies
- Encourage experimentation

### For Business Topics
- Include workplace scenarios
- Focus on ROI and practical outcomes
- Use case studies from various industries
- Include decision-making frameworks

## Quality Checklist

Before finalizing a course, ensure:

- [ ] **Story coherence**: Each story has clear beginning, middle, end
- [ ] **Character consistency**: Names and personalities remain consistent
- [ ] **Principle reinforcement**: Each story clearly demonstrates the concept
- [ ] **Question relevance**: Questions directly relate to preceding content
- [ ] **Explanation clarity**: All explanations are understandable and helpful
- [ ] **Flow smoothness**: Content transitions naturally between sections
- [ ] **Emotional engagement**: Content evokes curiosity, empathy, or surprise
- [ ] **Practical value**: Learners can apply insights to real situations
- [ ] **Appropriate length**: Course takes 10-15 minutes to complete
- [ ] **Technical correctness**: All content types and fields properly formatted

## Example Topics for New Courses

### Psychology-Based
- "The Invisible Psychology of Persuasion"
- "Why We Procrastinate (And How to Stop)"
- "The Science of First Impressions"

### Technology-Based
- "The Hidden Language of Code"
- "Why Apps Succeed or Fail"
- "The Psychology of User Experience"

### Life Skills
- "The Art of Effective Communication"
- "How to Make Better Decisions"
- "The Power of Habits"

## Final Notes

Remember: The goal is not just to inform, but to transform perspective. Great courses leave learners seeing the world differently and feeling empowered to apply new insights. Focus on the "aha!" moments that make learning memorable and meaningful.

The DesignExamplesShowcase (with 3 good and 3 bad examples) will be automatically added at the end of every course, so create courses knowing that learners will have a fun, interactive conclusion that reinforces the principles through humor and relatable examples.
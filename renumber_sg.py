#!/usr/bin/env python3
import re

# Renumbering plan:
# SG-ETH-07 (EEE) → SG-ETH-11
# SG-ETH-08 (Security) → SG-ETH-12
# SG-ETH-09 (AVTP) → SG-ETH-13
# SG-ETH-10 (vPHC) → SG-ETH-14
# New SG-ETH-07 = PHC
# FSC follows same renumbering

# We need to be careful about partial matches.
# Pattern: SG-ETH-07 must not match SG-ETH-07x or similar.
# We use word boundaries or explicit suffix checks.

def renumber_sg(content):
    # Step 1: FSC renumbering (with dot to avoid partial matches)
    # FSC-ETH-10.x → FSC-ETH-14.x (do 10 first to avoid 10→11 then 11→12 cascade)
    content = re.sub(r'FSC-ETH-10\.', 'FSC-ETH-14.', content)
    content = re.sub(r'FSC-ETH-09\.', 'FSC-ETH-13.', content)
    content = re.sub(r'FSC-ETH-08\.', 'FSC-ETH-12.', content)
    content = re.sub(r'FSC-ETH-07\.', 'FSC-ETH-11.', content)
    
    # Step 2: SG renumbering
    # Need to be very careful. Use negative lookahead/lookbehind.
    # SG-ETH-10 must not be part of SG-ETH-10x or SG-ETH-100
    # We match "SG-ETH-10" followed by non-digit or end of string.
    
    def replace_sg(match):
        num = int(match.group(1))
        mapping = {7: 11, 8: 12, 9: 13, 10: 14}
        new_num = mapping[num]
        return f'SG-ETH-{new_num:02d}'
    
    # Match SG-ETH-07, SG-ETH-08, SG-ETH-09, SG-ETH-10
    # Ensure it's not followed by a digit (to avoid matching SG-ETH-100)
    # And ensure it's not preceded by a digit or hyphen that would make it part of a larger number
    pattern = r'SG-ETH-(0[7-9]|10)(?!\d)'
    content = re.sub(pattern, replace_sg, content)
    
    # Step 3: Range updates
    # "SG-ETH-07~10" → "SG-ETH-11~14"
    content = content.replace('SG-ETH-07~10', 'SG-ETH-11~14')
    # "SG-ETH-01~10" → "SG-ETH-01~14"
    content = content.replace('SG-ETH-01~10', 'SG-ETH-01~14')
    
    # Step 4: Version history reference (leave as is since it's historical)
    # "新增 SG-ETH-07~10" in version history is historical and should stay as is
    # but if it's inside safety_concept.md, we need to decide.
    # Actually, version history is historical, so "SG-ETH-07~10" there refers to
    # the original PAD-REWORK-005 which added those. Since we're renumbering now,
    # it should be updated to reflect current numbering. But it's a changelog entry...
    # For consistency, let's update it too.
    
    return content

# Process safety_concept.md
with open('/root/.openclaw/workspace/sandbox/ethernet/Docs/FuSa/safety_concept.md', 'r') as f:
    content = f.read()

# Save original line count for verification
orig_lines = content.count('\n')

content = renumber_sg(content)

with open('/root/.openclaw/workspace/sandbox/ethernet/Docs/FuSa/safety_concept.md', 'w') as f:
    f.write(content)

new_lines = content.count('\n')
print(f'safety_concept.md: {orig_lines} lines → {new_lines} lines')

# Process parameter_safety_impact_matrix.md
with open('/root/.openclaw/workspace/sandbox/ethernet/Docs/FuSa/parameter_safety_impact_matrix.md', 'r') as f:
    content2 = f.read()

orig_lines2 = content2.count('\n')
content2 = renumber_sg(content2)

with open('/root/.openclaw/workspace/sandbox/ethernet/Docs/FuSa/parameter_safety_impact_matrix.md', 'w') as f:
    f.write(content2)

new_lines2 = content2.count('\n')
print(f'parameter_safety_impact_matrix.md: {orig_lines2} lines → {new_lines2} lines')

# Verify no old SG numbers remain (except in historical notes that shouldn't be updated)
# But we need to be careful: SG-ETH-07 now should only appear if we added the new PHC SG
# Let's check what remains
old_nums = ['SG-ETH-07', 'SG-ETH-08', 'SG-ETH-09', 'SG-ETH-10']
for fn in ['/root/.openclaw/workspace/sandbox/ethernet/Docs/FuSa/safety_concept.md',
           '/root/.openclaw/workspace/sandbox/ethernet/Docs/FuSa/parameter_safety_impact_matrix.md']:
    with open(fn, 'r') as f:
        text = f.read()
    for num in old_nums:
        count = text.count(num)
        if count > 0:
            print(f'WARNING: {num} still appears {count} times in {fn}')
            # Show context
            for m in re.finditer(re.escape(num), text):
                start = max(0, m.start() - 50)
                end = min(len(text), m.end() + 50)
                print(f'  ...{text[start:end]}...')

print('Renumbering complete.')

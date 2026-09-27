"""Generates lib/data/local/database/curriculum_data.dart."""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from curriculum_base import *  # noqa: F401,F403
from curriculum_base import LESSONS, QUIZ_QUESTIONS, FORMULAS, REFERENCES, generate


if __name__ == '__main__':
    import curriculum_c
    import curriculum_python
    import curriculum_java_dart
    import curriculum_architecture
    import curriculum_networks
    import curriculum_electronics
    import curriculum_data_comms
    import curriculum_physics
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                       '..', 'lib', 'data', 'local', 'database', 'curriculum_data.dart')
    with open(out, 'w') as f:
        f.write(generate())
    print('Generated %s (%d lessons, %d quiz questions, %d formulas, %d references)' % (
        out, len(LESSONS), len(QUIZ_QUESTIONS), len(FORMULAS), len(REFERENCES)))

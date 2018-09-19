#!/usr/bin/env python3
# Created by guzuxing on 9/13/18

import argparse
import os
from imspec_auditor.auditor import main_func


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--spec', dest='spec', default=None,
                        type=str, help='The location of the full spec file')
    parser.add_argument('--specDefine', dest='specDefine', default=None,
                        type=str, help='The location of the define files for spec file')
    parser.add_argument('--input', dest='input', default=None,
                        type=str, help='The location of input files')
    return parser.parse_args()


if __name__ == '__main__':
    args = get_args()
    spec = args.spec
    target = args.input
    specDefine = args.specDefine
    if spec is None:
        print("Please provide spec file by --spec=Path2Spec")
        exit(1)
    if not os.path.isfile(spec):
        print("Could not find spec file! " + spec)
        exit(1)
    if (not specDefine) and (not os.path.isfile(specDefine)):
        print("Could not find specDefine file! " + specDefine)
        exit(1)
    if target is None:
        print("Please provide target analysis file by --input=Path2Input")
        exit(1)
    if not os.path.isfile(target):
        print("Could not find input file! " + target)
        exit(1)
    if not str(target).endswith("ll"):
        print("Currently we only accept *.ll files as input, you can use clang -S -emit-llvm -g INPUT to generate it."
              "More details can be find in Readme!")
    print("User Input===>")
    print("Spec Location: {}\nInput Location: {}".format(spec, target))
    specPath = os.path.abspath(spec)
    specDefinePath = os.path.abspath(specDefine)
    targetPath = os.path.abspath(target)
    print("auditing spec file===>")
    audit = main_func(specPath, specDefinePath)
    auditPath = os.path.join(os.path.dirname(specPath), audit)
    resultPath = os.path.join(os.path.dirname(specPath), "IMCheckerResult.yaml")
    # print(auditPath)

    print("vetting API usages===>")
    cmdStr = "cd engine; bin/engine --config config/imchecker.top --spec {} {}".format(auditPath, targetPath)
    print(cmdStr)
    os.system(cmdStr)
    print("The checking result in {}".format(resultPath))
    print("Using report_displayer tool to validate the result:\n python3 report_displayer.py")

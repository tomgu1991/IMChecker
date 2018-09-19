import argparse
import os
import re
import shutil

import yaml

diff_pattern = re.compile('@@ -\d+,\d+ \+\d+,(\d+) @@')


class FileFilter:
    def __init__(self, config):
        self.config = config
        self.output_dir = os.path.expanduser(self.config['output']['dir'])
        self.final_dir = os.path.join(self.output_dir, 'diff_final')
        self.LOC = self.config['filter']['LOC']
        self.NOF = self.config['filter']['NOF']
        self.ignore_case = self.config['filter']['ignore_case']
        self.discard_file_name_list = self.config['filter']['file_name']
        self.discard_file_name_list_re_compile = []
        for name in self.discard_file_name_list:
            self.discard_file_name_list_re_compile.append(
                re.compile('[\s\S]*{}[\s\S]*'.format(name), re.I if self.ignore_case else 0))
        if not os.path.exists(self.final_dir):
            os.makedirs(self.final_dir)

    def start_filtering(self):
        filter_folder = None
        if self.config['output']['diff_result']:
            filter_folder = 'diff_result'
        else:
            print('No diff_result record, filter diff_all? (y/n)')
            raw_input = input()
            while raw_input != 'y' or raw_input != 'n' or raw_input != 'yes' or raw_input != 'no':
                print('Wrong input, try again. (y/n)')
                raw_input = input()
            if raw_input == 'n' or raw_input == 'no':
                print('Goodbye!')
                exit(0)
            else:
                filter_folder = 'diff_all'
        folder_path = os.path.join(self.output_dir, filter_folder)
        count = 0
        if not os.path.exists(folder_path):
            print('No diff record!')
            exit(-1)
        for _, dirs, _ in os.walk(folder_path):
            for commit_dir in dirs:
                for _, _, f in os.walk(os.path.join(folder_path, commit_dir)):
                    file_list = []
                    f.remove('description.txt')
                    for diff in f:
                        result = None
                        for pattern in self.discard_file_name_list_re_compile:
                            result = pattern.search(diff) if result is None else result
                        if result is None:  # no match
                            file_list.append(diff)
                    if self.NOF == -1 or 0 < len(file_list) <= self.NOF:
                        loc_list = []
                        for file in file_list:
                            with open(os.path.join(folder_path, commit_dir, file)) as f:
                                content = f.read()
                                diff_result = diff_pattern.findall(content)
                                loc = 0
                                for diff_loc in diff_result:
                                    loc += int(diff_loc)
                                loc_list.append(loc)
                        if self.LOC == -1 or sorted(loc_list)[-1] <= self.LOC:
                            shutil.copytree(os.path.join(folder_path, commit_dir),
                                            os.path.join(self.final_dir, commit_dir))
                            count += 1
                            print(count)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Grab useful message from git repository')
    parser.add_argument('--config',
                        dest='config_file',
                        help='location of config.yml file',
                        default='./config.yml',
                        type=str)
    args = parser.parse_args()
    config_file = None
    with open(args.config_file) as f:
        config_file = yaml.load(f.read())

    file_filter = FileFilter(config_file)
    file_filter.start_filtering()

import argparse
import datetime
import json
import os

import yaml
from git import GitCommandError
from git import NULL_TREE
from git import Repo

from db_filter import DBFilter
from db_recorder import DBRecorder
from file_filter import FileFilter

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Grab useful message from git repository')
    parser.add_argument('--config',
                        dest='config_file',
                        help='location of config.yml file',
                        default='./config.yml',
                        type=str)
    args = parser.parse_args()
    if not os.path.exists(args.config_file):
        print('No such config file!')
        exit(-1)
    config = None
    with open(args.config_file) as f:
        config = yaml.load(f.read())
    recorder = DBRecorder(config)
    recorder.create_db_table()

    diff_root = os.path.expanduser(os.path.join(config['output']['dir'], 'diff_all'))

    repo = Repo(config['working_dir'])

    skip = 0
    page_size = 100

    from_date = config['filter']['restrict']['from_date']
    from_date = datetime.datetime.strptime('1970-01-01' if from_date == -1 else str(from_date), '%Y-%m-%d')
    to_date = config['filter']['restrict']['to_date']
    to_date = datetime.datetime.strptime(
        str(datetime.date.today() + datetime.timedelta(days=1)) if to_date == -1 else str(to_date), '%Y-%m-%d')

    commit_count = 0
    commit_count_limit = int(config['filter']['restrict']['commit_count'])

    can_continue = True

    print('Start extracting...')
    while can_continue:
        try:
            commit_page = list(repo.iter_commits(config['filter']['branch'], max_count=page_size, skip=skip))
        except GitCommandError:
            print('No such branch or other error(s) happened.')
            exit(-1)
        last_commit_in_page = commit_page[-1]
        if last_commit_in_page.committed_datetime.replace(tzinfo=None) > to_date:
            skip += len(commit_page)
            continue
        for commit in commit_page:
            if commit_count_limit == -1 or commit_count < commit_count_limit:
                commit_date = commit.committed_datetime.replace(tzinfo=None)
                if commit_date > to_date:
                    continue
                if from_date <= commit_date:
                    record = {
                        'hash': commit.hexsha,
                        'summary': commit.summary,
                        'description': commit.message,
                        'date': str(commit_date),
                        'author': commit.author.name
                    }
                    parents = commit.parents
                    if len(parents) > 1:
                        # not tested
                        sorted_parents = sorted(parents, key=lambda x: x.committed_datetime)
                        latest = sorted_parents[-1]
                        diffs = latest.diff(commit, create_patch=True)
                        record['parent_hash'] = latest.hexsha
                    elif len(parents) == 1:
                        diffs = parents[0].diff(commit, create_patch=True)
                        record['parent_hash'] = parents[0].hexsha
                    else:
                        diffs = commit.diff(NULL_TREE, create_patch=True)
                    for diff in diffs:
                        diff_folder = os.path.join(diff_root, commit.hexsha)
                        if not os.path.exists(diff_folder):
                            os.makedirs(diff_folder)
                        file_name = diff.b_path if diff.a_path is None else diff.a_path
                        with open(os.path.join(diff_folder, file_name.replace('/', '\\') + '.diff'), 'w') as f:
                            f.write(str(diff))
                        with open(os.path.join(diff_folder, 'description.txt'), 'w') as f:
                            f.write(json.dumps(record, indent=4))
                    commit_count += 1
                    recorder.add_db_record(record)
                else:
                    can_continue = False
                    break
            else:
                can_continue = False
                break
            print('{} [{}][{}]'.format(commit_count, record['date'], record['summary']))
        if len(commit_page) == 0:
            break
        skip += len(commit_page)
    print('Extracting done...')

    print('Start filtering...')
    commit_count = 0
    db_filter = DBFilter(config, recorder.conn)
    db_filter.create_db()

    for first_level_keyword in config['filter']['key_words']['first']:
        if first_level_keyword is None:
            first_level_keyword = 'null'
        result = db_filter.filter(first_level_keyword, from_mid=False)
        for item in result:
            db_filter.add_db_record(item, is_final_result=False)
            commit_count += 1
            print(commit_count)

    commit_count = 0
    for second_level_keyword in config['filter']['key_words']['second']:
        if second_level_keyword is None:
            second_level_keyword = 'null'
        result = db_filter.filter(second_level_keyword, from_mid=True)
        for item in result:
            db_filter.add_db_record(item, is_final_result=True)
            commit_count += 1
            print(commit_count)

    file_filter = FileFilter(config)
    file_filter.start_filtering()

    recorder.close()
    print('All done!')

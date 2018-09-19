# GitGrabber
A script to grab specific info from specific git repo

#### Grab process

*Extract* git repo with specific restrict (commit count, or commit datetime interval) 👉 *Filter* git commit  using key words

#### Prerequisites

* python3
  * gitpython
  * pyyaml

Install them using pip or else.

* A handy sqlite browser - to view the result

#### How to use?

1. Download the git repo which you want to grab infomation from.

2. Download this repo.

3. Edit the config.yml file. Set the `working_dir` and `output.dir` fields and other fields that interests you.

4. `cd` to this repo.

5. Run script with `python main.py` or `python main.py --config config.yml`.

6. Extract result will be stored in the path you specified in `config.yml`.

   ##### The config file

   The config file is in yaml format.

   * `working_dir` denotes the path to the target git repo, this should point to the folder containing `.git` folder.
   * `filter` denotes the filter conditions.
     * `branch` denotes the target branch.
     * `restrict` denotes the first-level filter restriction.
       * `commit_count` denotes filtered result commit count, possible values: `-1` meaning unlimited or `[actual number]`.
       * `from_date` & `to_date` denote filtered result time interval, possible values: `-1` meaning unlimited or `[actual date]`.
     * `key_words` denotes the second-level filter restriction.
       * `first` denotes the first-level key word filter, usually some borad words.
       * `second` denotes the second-level key word filter, usually some specific words.
     * `LOC` is a part of the third-level filter restrictoins, it denotes the lines of diff code bound for each file. Those files whose lines of diff code is larger than this number will be discarded.
     * `NOF` is also a part of the third-level filter restrictions, it denotes the number of diff files bound for each commit. Those commits whose number of diff files is larger than this number will be discarded.
     * `file_name` is also a part of the third-level filter restrictions, it denotes those files whose name contains these words will be discarded.
   * `output` denotes info of output record.
     * `dir` denotes the path of result.
     * `file_name` denotes the sqlite db file name.
     * `diff_mid` & `diff_result` denotes whether outputting corresponding middle or final diff, recommended to set to `True`.

#### The result folder

original git repo =====filter.restrict=====> `diff_all` =====filter.key_words.first=====> `diff_mid` =====filter.key_words.second=====> `dif_result` =====filter.LOC & NOF & file_name & ignore_case =====> `diff_final`

result

* report.db (or name you specified in `config.yml`) - sqlite file storing meta data of each commit extracted
* diff_xxx - folder storing patches of each commit (`diff_all` for all commits, `diff_mid` for middle result from first level key words, `diff_result` for final result from second level key words)
  * description.txt - json-formatted file storing description data of this commit (same as corresponding row in report.db)
  * 1234…abcd - folder storing patch files of corresponding commit
    * a.diff - patch file
    * b.diff
  * abcd…1234
    * a.diff

#### The report.db

There are 3 tables after `All done!` prompt. The relationship among these 3 tables is as follow:

original git repo =====filter.restrict=====> `record` table =====filter.key_words.first=====> `mid` table =====filter.key_words.second=====> result

#### Note

1. sqlite in python can't use question marks ("?") in LIKE sentence, so MAY CAUSE SQL INJECTION ATTACK IN KEYWORD FIELD!!!
2. Filter process may suffer from performance problem.
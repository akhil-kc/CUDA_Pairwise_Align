#ifndef _DNA_H
#define _DNA_H


class DNA {
  public:
    DNA();
    ~DNA();
    bool read_file(char * file_name);
    char *seq_string;
    int seq_length;
};

#endif


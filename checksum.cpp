#include<iostream>
#include<unistd.h>
#include<string.h>
using namespace std;

int main(int argc, char const *argv[])
{
    
    unsigned char c;
    unsigned long long checksum;
    for (int i = 1; i < argc; i++)
    {
        //cout<<argv[i]<<endl;
        int length=strlen(argv[i]);
        for (int j = 0; j < length; j++)
        {
            c = static_cast<unsigned char>(argv[i][j]);
            checksum+=c;
        }
        
    }
    printf("%.6o", checksum);

    return 0;
}
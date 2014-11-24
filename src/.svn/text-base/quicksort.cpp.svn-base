#include "quicksort.h"
using namespace std;
using namespace xCloud;

void QuickSort::quicksort(int a[], int low, int high) {
    if (low >= high) {
        return;
    }
    int first = low;
    int last = high;
    /*用字表的第一个记录作为枢轴*/
    int key = a[first];
    int tmp;
    while(first < last) {
        while(first < last && a[last] >= key) {
            --last;
        }
        while(first < last && a[first] <= key) {
            ++first;
        }
        //交换两个数在数组中的位置
        if(first < last) {
            tmp = a[first];
            a[first] = a[last];
            a[last] = tmp;
        }
    }
    /*枢轴记录到位*/
    a[low] = a[first];
    a[first] = key;
    
    QuickSort::quicksort(a, low, first - 1);
    QuickSort::quicksort(a, first + 1, high);
}




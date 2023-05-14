
```cpp
clock_t start, end;
start = clock();
...
end = clock();
cout << "Time = " << (end - start) / CLOCKS_PER_SEC << "s" << endl;
```


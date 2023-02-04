using System;
using UnityEngine;

public class Cooldown
{
    public float duration = 1f, endTime;

    public bool HasEnded => Time.time > endTime;

    public float TimeRemaining => Math.Max(0, endTime - Time.time);

    public void StartCoolDown()
    {
        endTime = Time.time + duration;
    }

    public void StartCoolDown(float duration)
    {
        endTime = Time.time + duration;
        this.duration = duration;
    }

    public void ChangeDuration(float duration)
    {
        this.duration = duration;
        endTime = Time.time + duration;
    }
}
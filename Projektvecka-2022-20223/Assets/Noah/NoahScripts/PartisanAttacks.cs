using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PartisanAttacks : MonoBehaviour
{
    private Animator anim;
    public float cooldownTime = 2f;
    private float nextFireTime = 0f;
    public static int noOfClicks = 0;
    float lastClickedTime = 1;
    float maxComboDelay = 1;

    private void Start()
    {
        anim = GetComponent<Animator>();

       // playerInput = new PlayerInput();
    }
    /*
    private void OnEnable()
    {
        playerInput.Player.Enable();
    }
    private void OnDisable()
    {
        playerInput.Player.Disable();
    }
    */
    void Update()
    {
        if (anim.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && anim.GetCurrentAnimatorStateInfo(0).IsName("Combo1"))
        {
            anim.SetBool("Combo1", false);
        }
        if (anim.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && anim.GetCurrentAnimatorStateInfo(0).IsName("Combo2"))
        {
            anim.SetBool("Combo2", false);
        }
        if (anim.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && anim.GetCurrentAnimatorStateInfo(0).IsName("Combo3"))
        {
            anim.SetBool("Combo3", false);
            noOfClicks = 0;
        }


        if (Time.time - lastClickedTime > maxComboDelay)
        {
            noOfClicks = 0;
        }
    }

    public void Onclick()
    {
        if (Time.time <= nextFireTime) return;
        //so it looks at how many clicks have been made and if one animation has finished playing starts another one.
        lastClickedTime = Time.time;
        noOfClicks++;
        if (noOfClicks == 1)
        {
            anim.SetBool("Combo1", true);
            anim.SetBool("Combo2", false);
            anim.SetBool("Combo3", false);
        }
        noOfClicks = Mathf.Clamp(noOfClicks, 0, 3);

        if (noOfClicks >= 2 && anim.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && anim.GetCurrentAnimatorStateInfo(0).IsName("Combo1"))
        {
            anim.SetBool("Combo1", false);
            anim.SetBool("Combo2", true);
        }
        if (noOfClicks >= 3 && anim.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && anim.GetCurrentAnimatorStateInfo(0).IsName("Combo2"))
        {
            anim.SetBool("Combo2", false);
            anim.SetBool("Combo3", true);
        }
    }
}
